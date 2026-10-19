import json
from pathlib import Path
from uuid import uuid4
import pytest
from pydantic import ValidationError
from app.nutrition_contracts import ProductData, PushRequest, EntryData, ProductSnapshot
from app.export_nutrition_contract import build_contract

def product_change(**overrides):
    return {'entity': 'product', 'mutationId': str(uuid4()), 'id': str(uuid4()),
      'operation': 'upsert', 'baseVersion': 0, 'clientRevision': 1,
      'data': {'name': 'Рис', 'calories': 130, 'protein': 2.7, 'fat': .3, 'carbs': 28}, **overrides}

@pytest.mark.parametrize('field,value', [('calories', -1), ('calories', 901), ('protein', float('nan')),
  ('fat', float('inf')), ('name', '  '), ('carbs', 101)])
def test_contract_invalid_product(field, value):
    data = product_change()['data']; data[field] = value
    with pytest.raises(ValidationError): ProductData.model_validate(data)

def test_contract_macro_mass_and_unknown_fields():
    with pytest.raises(ValidationError): ProductData(name='bad', calories=100, protein=50, fat=60, carbs=0)
    change = product_change(); change['data']['userId'] = str(uuid4())
    with pytest.raises(ValidationError): PushRequest.model_validate({'changes': [change]})

def test_contract_batch_bounds_duplicates_tombstones_and_uuid():
    assert PushRequest.model_validate({'changes': [product_change()]}).changes[0].data.name == 'Рис'
    for changes in ([], [product_change()] * 101):
        with pytest.raises(ValidationError): PushRequest(changes=changes)
    duplicate = product_change()
    with pytest.raises(ValidationError): PushRequest.model_validate({'changes': [duplicate, duplicate]})
    tombstone = product_change(operation='delete', data=None, baseVersion=1)
    assert PushRequest.model_validate({'changes': [tombstone]}).changes[0].data is None
    with pytest.raises(ValidationError): PushRequest.model_validate({'changes': [product_change(operation='delete')]})
    with pytest.raises(ValidationError): PushRequest.model_validate({'changes': [product_change(id='not-a-uuid')]})

def test_entry_snapshot_must_match_product():
    with pytest.raises(ValidationError): EntryData(meal_id=uuid4(), product_id=uuid4(), grams=100,
      snapshot=ProductSnapshot(id=uuid4(), name='rice', calories=130, protein=2.7, fat=.3, carbs=28))

def test_exported_openapi_is_current_and_every_ref_resolves():
    path = Path(__file__).resolve().parents[2] / 'docs/nutrition-openapi.json'
    saved = json.loads(path.read_text(encoding='utf-8'))
    assert saved == build_contract()
    assert 'Contract only' in saved['info']['description']
    def visit(node):
        if isinstance(node, dict):
            if '$ref' in node:
                current = saved
                for part in node['$ref'].removeprefix('#/').split('/'):
                    current = current[part]
            for value in node.values(): visit(value)
        elif isinstance(node, list):
            for value in node: visit(value)
    visit(saved)

def test_actual_dart_outbox_example_matches_python_contract():
    path = Path(__file__).resolve().parents[2] / 'docs/nutrition-push.example.json'
    request = PushRequest.model_validate_json(path.read_text(encoding='utf-8'))
    assert [change.entity for change in request.changes] == ['product', 'meal', 'entry']
    assert request.changes[2].data.grams == 125
    assert request.changes[2].data.snapshot.calories == 130

@pytest.mark.parametrize('payload', [
  {'entity': 'meal', 'data': {'name': 'wrong kind', 'calories': 0, 'protein': 0, 'fat': 0, 'carbs': 0}},
  {'entity': 'product', 'data': None},
  {'entity': 'product', 'data': {'name': 'rice', 'calories': 130, 'protein': 2.7, 'fat': .3, 'carbs': 28}, 'deletedAt': '2026-10-18T00:00:00Z'},
])
def test_pull_rejects_invalid_entity_or_tombstone(payload):
    from app.nutrition_contracts import ChangeRecord
    with pytest.raises(ValidationError):
        ChangeRecord.model_validate({'id': str(uuid4()), 'version': 1, 'updatedAt': '2026-10-18T00:00:00Z', **payload})
