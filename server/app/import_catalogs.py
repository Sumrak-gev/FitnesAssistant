"""Explicit server-side imports; never called by a phone's search request."""
import argparse
import json
from pathlib import Path
import time
from uuid import NAMESPACE_URL, uuid5

import httpx
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.database import get_engine
from app.nutrition_contracts import ProductData
from app.sync_contracts import ExerciseData
from app.sync_models import CatalogProduct, CatalogExercise

EXERCISES_URL = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json'
MUSCLES = {'quadriceps': 'ноги', 'hamstrings': 'ноги', 'calves': 'ноги', 'glutes': 'ноги',
           'chest': 'грудь', 'lats': 'спина', 'middle back': 'спина', 'lower back': 'спина',
           'abdominals': 'пресс', 'shoulders': 'плечи', 'biceps': 'руки', 'triceps': 'руки'}
EQUIPMENT = {'barbell': 'штанга', 'dumbbell': 'гантели', 'body only': 'без инвентаря',
             'machine': 'тренажёр', 'cable': 'тренажёр'}


def off_product(item):
    nutrients = item['nutriments']
    energy = nutrients.get('energy-kcal_100g')
    if energy is None:
        energy = float(nutrients['energy-kj_100g']) / 4.184
    data = ProductData(name=(item.get('product_name_ru') or item['product_name']).strip()[:120],
                       calories=float(energy), protein=float(nutrients['proteins_100g']), fat=float(nutrients['fat_100g']),
                       carbs=float(nutrients['carbohydrates_100g']))
    code = str(item['code'])
    if not code.isdigit() or len(code) > 40:
        raise ValueError('Invalid barcode')
    return CatalogProduct(id=uuid5(NAMESPACE_URL, f'off:{code}'), source_id=f'off:{code}',
        name=data.name, data=data.model_dump(mode='json'), source_url=f'https://world.openfoodfacts.org/product/{code}',
        license='Open Food Facts — ODbL 1.0 / Database Contents License')


def exercise(item):
    source_id = str(item['id'])
    entity_id = uuid5(NAMESPACE_URL, f'free-exercise-db:{source_id}')
    muscle = next(iter(item['primaryMuscles']), 'другое')
    equipment = item.get('equipment') or 'body only'
    data = ExerciseData(id=str(entity_id), name=item['name'][:120],
        muscle_group=MUSCLES.get(muscle, muscle), equipment=EQUIPMENT.get(equipment, equipment), contraindications=[])
    return CatalogExercise(id=entity_id, source_id=f'free-exercise-db:{source_id}', name=data.name,
        data=data.model_dump(mode='json', by_alias=True, exclude={'id'}),
        source_url='https://github.com/yuhonas/free-exercise-db', license='The Unlicense (public domain)')


def import_items(session, source, items):
    imported = skipped = 0
    for item in items:
        try:
            row = off_product(item) if source == 'off' else exercise(item)
        except (KeyError, ValueError, TypeError, ValidationError):
            skipped += 1
            continue
        session.merge(row)  # Stable UUIDs make repeated imports idempotent.
        imported += 1
    session.commit()
    return imported, skipped


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', choices=['off', 'exercises'])
    parser.add_argument('--file', type=Path, help='Import a previously downloaded JSON snapshot')
    parser.add_argument('--user-agent', help='App/version and maintainer contact; required for network imports')
    parser.add_argument('--pages', type=int, default=1)
    parser.add_argument('--country', default='en:russia')
    args = parser.parse_args()
    if not 1 <= args.pages <= 20:
        parser.error('--pages must be 1–20')
    if not args.file and not args.user_agent:
        parser.error('Provide --user-agent with your maintainer contact')
    with Session(get_engine()) as session:
        if args.file:
            snapshot = json.loads(args.file.read_text(encoding='utf-8'))
            items = snapshot['products'] if args.source == 'off' else snapshot
            print(import_items(session, args.source, items))
            return
        with httpx.Client(headers={'User-Agent': args.user_agent}, timeout=60, follow_redirects=False) as client:
            if args.source == 'exercises':
                response = client.get(EXERCISES_URL)
                response.raise_for_status()
                print(import_items(session, args.source, response.json()))
            else:
                for page in range(1, args.pages + 1):
                    if page > 1:
                        time.sleep(7)  # Respect OFF's search rate limit; imports run outside HTTP handlers.
                    response = client.get('https://world.openfoodfacts.org/api/v2/search', params={
                        'countries_tags': args.country, 'page': page, 'page_size': 100,
                        'fields': 'code,product_name,product_name_ru,nutriments'})
                    response.raise_for_status()
                    print(import_items(session, args.source, response.json()['products']))


if __name__ == '__main__':
    main()
