import json
from pathlib import Path
from pydantic.json_schema import models_json_schema
from app.nutrition_contracts import PushRequest, PushResponse, PullResponse, SyncError

def build_contract():
    _, schema = models_json_schema([(m, 'validation') for m in (PushRequest, PushResponse, PullResponse, SyncError)],
      ref_template='#/components/schemas/{model}')
    response = lambda name: {'description': name, 'content': {'application/json': {'schema': {'$ref': f'#/components/schemas/{name}'}}}}
    errors = {str(code): response('SyncError') for code in (401, 409, 410, 422)}
    return {'openapi': '3.1.0', 'info': {'title': 'Fitness nutrition sync contract', 'version': '1.0.0',
      'description': 'Contract only. Routes are not mounted until authentication and the sync transport are implemented.'},
      'security': [{'bearerAuth': []}], 'paths': {
        '/v1/nutrition/sync/push': {'post': {'operationId': 'pushNutrition',
          'requestBody': {'required': True, 'content': {'application/json': {'schema': {'$ref': '#/components/schemas/PushRequest'}}}},
          'responses': {'200': response('PushResponse'), **errors}}},
        '/v1/nutrition/sync/pull': {'get': {'operationId': 'pullNutrition', 'parameters': [
          {'in': 'query', 'name': 'cursor', 'schema': {'type': 'string'}},
          {'in': 'query', 'name': 'limit', 'schema': {'type': 'integer', 'minimum': 1, 'maximum': 500, 'default': 100}}],
          'responses': {'200': response('PullResponse'), **errors}}}},
      'components': {'securitySchemes': {'bearerAuth': {'type': 'http', 'scheme': 'bearer', 'bearerFormat': 'JWT'}},
        'schemas': schema['$defs']}}

if __name__ == '__main__':
    path = Path(__file__).resolve().parents[2] / 'docs/nutrition-openapi.json'
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(build_contract(), ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(path.name, 'generated')
