from pydantic import ValidationError
import pytest
from app.import_catalogs import off_product, exercise


def test_off_normalization_stable_ids_and_incomplete_records():
    item = {'code': '4601234567890', 'product_name': 'Rice', 'product_name_ru': 'Рис',
            'nutriments': {'energy-kcal_100g': 130, 'proteins_100g': 2.7, 'fat_100g': .3, 'carbohydrates_100g': 28}}
    first, second = off_product(item), off_product(item)
    assert first.id == second.id and first.name == 'Рис'
    assert first.data['calories'] == 130
    assert 'ODbL' in first.license and first.source_url.endswith(item['code'])
    with pytest.raises(KeyError):
        off_product({**item, 'nutriments': {}})
    with pytest.raises(ValidationError):
        off_product({**item, 'nutriments': {**item['nutriments'], 'proteins_100g': 120}})


def test_exercises_normalize_equipment_without_inventing_contraindications():
    row = exercise({'id': 'Barbell_Squat', 'name': 'Barbell Squat', 'primaryMuscles': ['quadriceps'], 'equipment': 'barbell'})
    assert row.data['muscleGroup'] == 'ноги'
    assert row.data['equipment'] == 'штанга'
    assert row.data['contraindications'] == []
    assert 'Unlicense' in row.license
