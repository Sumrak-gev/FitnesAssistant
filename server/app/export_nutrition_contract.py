"""Export the schema of the mounted API; filename retained for existing links."""
import json
from pathlib import Path
from app.main import app


def build_contract():
    return app.openapi()


if __name__ == '__main__':
    path = Path(__file__).resolve().parents[2] / 'docs/nutrition-openapi.json'
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(build_contract(), ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(path.name, 'generated')
