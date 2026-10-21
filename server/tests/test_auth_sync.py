from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
import os
from uuid import uuid4

import jwt
import pytest
from argon2 import PasswordHasher
from fastapi.testclient import TestClient
from fastapi import HTTPException, Request
from sqlalchemy import create_engine, select
from sqlalchemy.engine import make_url
from sqlalchemy.orm import Session

from app.auth import limiter, digest
from app.config import get_settings
from app.database import get_session
from app.main import app
from app.models import User, RefreshToken
from app.sync_models import CatalogProduct


@pytest.fixture
def api():
    url = os.environ.get('TEST_DATABASE_URL')
    if not url:
        pytest.skip('Requires isolated migrated PostgreSQL fitness_test')
    if make_url(url).database != 'fitness_test':
        pytest.fail('Refusing non-test database')
    engine = create_engine(url)
    connection = engine.connect()
    transaction = connection.begin()
    def sessions():
        with Session(bind=connection, join_transaction_mode='create_savepoint', expire_on_commit=False) as session:
            yield session
    app.dependency_overrides[get_session] = sessions
    limiter.buckets.clear()
    try:
        yield TestClient(app), connection
    finally:
        app.dependency_overrides.clear()
        transaction.rollback()
        connection.close()
        engine.dispose()


def account(client, *, email=None, device=None):
    data = {'email': email or f'{uuid4()}@example.com', 'password': 'long-test-password-42',
            'display_name': 'Денис', 'device_id': device or str(uuid4())}
    response = client.post('/auth/register', json=data)
    assert response.status_code == 201, response.text
    return data, response.json()


def headers(tokens):
    return {'Authorization': f"Bearer {tokens['access_token']}"}


def change(entity='product', data=None, **values):
    return {'mutationId': str(uuid4()), 'id': str(uuid4()), 'entity': entity, 'operation': 'upsert',
            'baseVersion': 0, 'clientRevision': 1, 'data': data or {
                'name': 'Рис', 'calories': 130, 'protein': 2.7, 'fat': .3, 'carbs': 28}, **values}


def send(client, tokens, *changes):
    return client.post('/sync/push', headers=headers(tokens), json={'changes': list(changes)})


def test_registration_hash_email_login_and_validation_redaction(api):
    client, connection = api
    credentials, tokens = account(client)
    with Session(connection) as session:
        user = session.scalar(select(User).where(User.email == credentials['email']))
        assert user.password_hash.startswith('$argon2id$')
        assert PasswordHasher().verify(user.password_hash, credentials['password'])
        refresh = session.scalar(select(RefreshToken).where(RefreshToken.token_hash == digest(tokens['refresh_token'])))
        assert refresh is not None
        assert refresh.token_hash != tokens['refresh_token']
    assert 'password' not in tokens and 'password_hash' not in tokens
    duplicate = client.post('/auth/register', json={**credentials, 'email': credentials['email'].upper()})
    assert duplicate.status_code == 409
    login = {k: v for k, v in credentials.items() if k != 'display_name'}
    assert client.post('/auth/login', json={**login, 'email': credentials['email'].upper()}).status_code == 200
    assert client.post('/auth/login', json={**login, 'password': 'incorrect-password'}).status_code == 401
    response = client.post('/auth/register', json={**credentials, 'password': 'SECRET'})
    assert response.status_code == 422 and 'SECRET' not in response.text
    assert client.post('/auth/register', json={**credentials, 'user_id': str(uuid4())}).status_code == 422


def test_refresh_rotation_replay_revokes_chain_and_access(api):
    client, _ = api
    credentials, first = account(client)
    body = {'refresh_token': first['refresh_token'], 'device_id': credentials['device_id']}
    second = client.post('/auth/refresh', json=body)
    assert second.status_code == 200
    second = second.json()
    assert second['refresh_token'] != first['refresh_token']
    assert client.get('/sync/pull', headers=headers(second)).status_code == 200
    assert client.post('/auth/refresh', json=body).status_code == 401
    assert client.post('/auth/refresh', json={**body, 'refresh_token': second['refresh_token']}).status_code == 401
    assert client.get('/sync/pull', headers=headers(second)).status_code == 401


def test_device_binding_logout_and_access_expiry(api):
    client, _ = api
    credentials, tokens = account(client)
    body = {'refresh_token': tokens['refresh_token'], 'device_id': str(uuid4())}
    assert client.post('/auth/refresh', json=body).status_code == 401
    assert client.get('/sync/pull', headers=headers(tokens)).status_code == 200
    claims = jwt.decode(tokens['access_token'], get_settings().jwt_secret.get_secret_value(),
                        algorithms=['HS256'], audience='fitness-android', issuer='fitness-assistant')
    claims['exp'] = datetime.now(timezone.utc) - timedelta(seconds=1)
    expired = {**tokens, 'access_token': jwt.encode(claims, get_settings().jwt_secret.get_secret_value(), algorithm='HS256')}
    assert client.get('/sync/pull', headers=headers(expired)).status_code == 401
    assert client.post('/auth/logout', json={**body, 'device_id': credentials['device_id']}).status_code == 204
    assert client.get('/sync/pull', headers=headers(tokens)).status_code == 401


def test_idempotent_push_versions_and_atomic_batch(api):
    client, _ = api
    _, tokens = account(client)
    product = change()
    first = send(client, tokens, product)
    assert first.status_code == 200, first.text
    assert send(client, tokens, product).json() == first.json()
    equivalent = send(client, tokens, {**product, 'mutationId': str(uuid4())})
    assert equivalent.status_code == 200 and equivalent.json()['applied'][0]['version'] == 1
    assert send(client, tokens, {**product, 'data': {**product['data'], 'name': 'tamper'}}).status_code == 409
    stale = change(id=product['id'], clientRevision=2)
    assert send(client, tokens, stale).status_code == 409
    fresh = change()
    assert send(client, tokens, fresh, stale).status_code == 409
    pull = client.get('/sync/pull', headers=headers(tokens)).json()
    assert len(pull['changes']) == 1  # failed batch did not partially commit
    assert client.get('/sync/pull', headers=headers(tokens), params={'since': pull['nextCursor']}).json()['changes'] == []


def test_full_offline_push_pull_second_device_and_user_isolation(api):
    client, _ = api
    credentials, a = account(client)
    login = {k: v for k, v in credentials.items() if k != 'display_name'}
    login['device_id'] = str(uuid4())
    b = client.post('/auth/login', json=login).json()
    _, stranger = account(client)
    product = change()
    meal = change('meal', {'day': '2026-10-20', 'kind': 'lunch'})
    entry = change('entry', {'mealId': meal['id'], 'productId': product['id'], 'grams': 125,
                            'snapshot': {'id': product['id'], **product['data']}})
    assert send(client, a, product, meal, entry).status_code == 200
    changes = client.get('/sync/pull', headers=headers(b)).json()['changes']
    assert [c['entity'] for c in changes] == ['product', 'meal', 'entry']
    assert changes[2]['data']['grams'] * changes[2]['data']['snapshot']['calories'] / 100 == 162.5
    assert client.get('/sync/pull', headers=headers(stranger)).json()['changes'] == []
    assert send(client, stranger, entry).status_code == 409
    assert send(client, stranger, product).status_code == 409
    own_meal = change('meal', meal['data'])
    assert send(client, b, own_meal).json()['detail']['canonicalId'] == meal['id']
    tombstone = {**meal, 'mutationId': str(uuid4()), 'operation': 'delete', 'data': None,
                 'baseVersion': 1, 'clientRevision': 2}
    assert send(client, a, tombstone).status_code == 200
    pulled = client.get('/sync/pull', headers=headers(b)).json()['changes']
    assert pulled[-2]['entity'] == 'entry' and pulled[-2]['deletedAt'] is not None
    assert pulled[-1]['entity'] == 'meal' and pulled[-1]['deletedAt'] is not None


def test_pull_pagination_bound_cursor_and_validation(api):
    client, _ = api
    _, a = account(client)
    _, b = account(client)
    assert client.get('/sync/pull').status_code == 401
    assert send(client, a, change(), change(), change()).status_code == 200
    first = client.get('/sync/pull?limit=1', headers=headers(a)).json()
    assert first['hasMore'] and len(first['changes']) == 1
    second = client.get('/sync/pull', params={'since': first['nextCursor'], 'limit': 2}, headers=headers(a)).json()
    assert not second['hasMore'] and len(second['changes']) == 2
    assert client.get('/sync/pull', params={'since': first['nextCursor']}, headers=headers(b)).status_code == 410
    assert client.get('/sync/pull?since=999.bad', headers=headers(a)).status_code == 410
    assert send(client, a, change(data={'name': 'bad', 'calories': -1, 'protein': 0, 'fat': 0, 'carbs': 0})).status_code == 422
    assert send(client, a, change('progress', {'day': '2026-10-20', 'workoutDone': True, 'caloriesConsumed': 1800})).status_code == 200
    assert client.get('/products?q=%25%27%20OR%201=1', headers=headers(a)).status_code == 200


def test_auth_rate_limit_and_cors(api, monkeypatch):
    client, _ = api
    monkeypatch.setattr(get_settings(), 'auth_limit', 2)
    credentials, _ = account(client)
    login = {k: v for k, v in credentials.items() if k != 'display_name'}
    # Successful logins are not failed attempts and do not consume the quota.
    assert client.post('/auth/login', json=login).status_code == 200
    assert client.post('/auth/login', json=login).status_code == 200
    body = {'email': 'absent@example.com', 'password': 'long-test-password', 'device_id': str(uuid4())}
    assert client.post('/auth/login', json=body).status_code == 401
    assert client.post('/auth/login', json=body).status_code == 401
    assert client.post('/auth/login', json=body).status_code == 429
    response = client.options('/sync/push', headers={'Origin': 'https://evil.example', 'Access-Control-Request-Method': 'POST'})
    assert 'access-control-allow-origin' not in response.headers


def test_failed_attempts_limit_account_across_client_ips(monkeypatch):
    monkeypatch.setattr(get_settings(), 'auth_limit', 2)
    limiter.buckets.clear()
    first = Request({'type': 'http', 'client': ('203.0.113.10', 1000)})
    second = Request({'type': 'http', 'client': ('203.0.113.11', 1000)})
    limiter.failed(first, 'USER@example.com')
    limiter.failed(first, 'user@example.com')
    with pytest.raises(HTTPException) as blocked_account:
        limiter.check(second, 'user@example.com')
    assert blocked_account.value.status_code == 429
    limiter.check(second, 'another@example.com')
    with pytest.raises(HTTPException):
        limiter.check(first, 'another@example.com')


def test_concurrent_refresh_replay_cannot_create_two_live_children():
    url = os.environ.get('TEST_DATABASE_URL')
    if not url:
        pytest.skip('Requires PostgreSQL fitness_test')
    if make_url(url).database != 'fitness_test':
        pytest.fail('Refusing non-test database')
    engine = create_engine(url)
    def sessions():
        with Session(engine, expire_on_commit=False) as session:
            yield session
    app.dependency_overrides[get_session] = sessions
    limiter.buckets.clear()
    user_id = None
    try:
        client = TestClient(app)
        credentials, original = account(client)
        user_id = original['user_id']
        body = {'refresh_token': original['refresh_token'], 'device_id': credentials['device_id']}
        with ThreadPoolExecutor(max_workers=2) as pool:
            responses = list(pool.map(lambda _: TestClient(app).post('/auth/refresh', json=body), range(2)))
        assert sorted(r.status_code for r in responses) == [200, 401]
        child = next(r.json() for r in responses if r.status_code == 200)
        assert client.get('/sync/pull', headers=headers(child)).status_code == 401
    finally:
        app.dependency_overrides.clear()
        if user_id:
            from uuid import UUID
            with engine.begin() as connection:
                connection.execute(User.__table__.delete().where(User.id == UUID(user_id)))
        engine.dispose()


def test_catalog_search_is_case_insensitive_for_russian_on_locale_c(api):
    client, connection = api
    _, tokens = account(client)
    product_id = uuid4()
    with Session(connection, join_transaction_mode='create_savepoint') as session:
        session.add(CatalogProduct(id=product_id, source_id=f'test:{product_id}', name='РуСтЕсТ',
            data={'name': 'РуСтЕсТ', 'calories': 130, 'protein': 2.7, 'fat': .3, 'carbs': 28},
            source_url='https://world.openfoodfacts.org/', license='ODbL 1.0'))
        session.commit()
    response = client.get('/products', params={'q': 'РУСТЕСТ'}, headers=headers(tokens))
    assert response.status_code == 200
    assert response.json()[0]['id'] == str(product_id)
