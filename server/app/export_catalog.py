"""Export the derived OFF catalog for redistribution under ODbL; excludes user diaries."""
import json
import sys
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.database import get_engine
from app.sync_models import CatalogProduct


if __name__ == '__main__':
    with Session(get_engine()) as session:
        data = [{'id': str(r.id), **r.data, 'sourceUrl': r.source_url, 'license': r.license}
                for r in session.scalars(select(CatalogProduct).order_by(CatalogProduct.id))]
    sys.stdout.reconfigure(encoding='utf-8')
    print(json.dumps({'source': 'Open Food Facts', 'license': 'ODbL 1.0', 'products': data}, ensure_ascii=False))
