import 'dart:convert';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:fitness_assistant/core/api/api_client.dart';
import 'package:fitness_assistant/core/db/app_database.dart';
import 'package:fitness_assistant/core/sync/database_lease.dart';
import 'package:drift/native.dart';
import 'support/memory_token_store.dart';

void main() {
  test('Logout cannot be undone by an in-flight background refresh', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final store = MemoryTokenStore();
    final started = Completer<void>(), release = Completer<void>();
    Future<http.Response> respond(http.Request request) async {
      if (request.url.path == '/auth/refresh') {
        started.complete();
        await release.future;
        return http.Response(
          jsonEncode({
            'access_token': 'fresh',
            'refresh_token': 'rotated',
            'user_id': 'user',
          }),
          200,
        );
      }
      if (request.url.path == '/auth/logout') return http.Response('', 204);
      return http.Response('{}', 401);
    }

    final foreground = ApiClient(
      baseUrl: 'http://localhost',
      store: store,
      client: MockClient(respond),
      refreshGuard: DatabaseLease(db, 'refresh').guardRefresh,
    );
    final background = ApiClient(
      baseUrl: 'http://localhost',
      store: store,
      client: MockClient(respond),
      refreshGuard: DatabaseLease(db, 'refresh').guardRefresh,
    );
    try {
      await foreground.accept(
        AccountSession.fromJson({
          'access_token': 'old',
          'refresh_token': 'old',
          'user_id': 'user',
          'device_id': 'device',
        }),
      );
      await background.restore();
      final request = background.request('GET', '/sync/pull');
      final rejected = expectLater(request, throwsA(isA<ApiException>()));
      await started.future;
      final logout = foreground.logout();
      while (foreground.session != null) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      release.complete();
      await rejected;
      await logout;
      expect(store.values['session'], isNull);
      expect(background.session, isNull);
      await foreground.restore();
      expect(foreground.session, isNull);
    } finally {
      foreground.dispose();
      background.dispose();
      await db.close();
    }
  });
  test(
    'Foreground and background clients share refresh rotation and SQLite lease',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = MemoryTokenStore();
      var rotations = 0;
      Future<http.Response> respond(http.Request request) async {
        if (request.url.path == '/auth/refresh') {
          rotations++;
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response(
            jsonEncode({
              'access_token': 'fresh',
              'refresh_token': 'rotated',
              'user_id': 'user',
            }),
            200,
          );
        }
        return http.Response(
          '[]',
          request.headers['Authorization'] == 'Bearer fresh' ? 200 : 401,
        );
      }

      final a = ApiClient(
        baseUrl: 'http://localhost',
        store: store,
        client: MockClient(respond),
        refreshGuard: DatabaseLease(db, 'refresh').guardRefresh,
      );
      final b = ApiClient(
        baseUrl: 'http://localhost',
        store: store,
        client: MockClient(respond),
        refreshGuard: DatabaseLease(db, 'refresh').guardRefresh,
      );
      try {
        await a.accept(
          AccountSession.fromJson({
            'access_token': 'old',
            'refresh_token': 'old',
            'user_id': 'user',
            'device_id': 'device',
          }),
        );
        await b.restore();
        await Future.wait([
          a.request('GET', '/sync/pull'),
          b.request('GET', '/products'),
        ]);
        expect(rotations, 1);
        expect(a.session!.refresh, 'rotated');
        expect(b.session!.refresh, 'rotated');
        final leaseA = DatabaseLease(db, 'sync'),
            leaseB = DatabaseLease(db, 'sync');
        expect(await leaseA.acquire(), isTrue);
        expect(await leaseB.acquire(), isFalse);
        await leaseA.release();
        expect(await leaseB.acquire(), isTrue);
        await leaseB.release();
      } finally {
        a.dispose();
        b.dispose();
        await db.close();
      }
    },
  );
  test(
    'Parallel 401 responses rotate once and persist the complete session',
    () async {
      var rotations = 0;
      final store = MemoryTokenStore();
      final api = ApiClient(
        baseUrl: 'http://localhost',
        store: store,
        client: MockClient((request) async {
          if (request.url.path == '/auth/refresh') {
            rotations++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return http.Response(
              jsonEncode({
                'access_token': 'fresh',
                'refresh_token': 'rotated',
                'user_id': 'user',
              }),
              200,
            );
          }
          return request.headers['Authorization'] == 'Bearer fresh'
              ? http.Response('[]', 200)
              : http.Response('{}', 401);
        }),
      );
      addTearDown(api.dispose);
      await api.accept(
        AccountSession.fromJson({
          'access_token': 'expired',
          'refresh_token': 'old',
          'user_id': 'user',
          'device_id': 'device',
        }),
      );
      await Future.wait([
        api.request('GET', '/sync/pull'),
        api.request('GET', '/products'),
      ]);
      expect(rotations, 1);
      expect(jsonDecode(store.values['session']!)['refresh_token'], 'rotated');
    },
  );

  test(
    'Offline refresh preserves credentials; rejected refresh clears them',
    () async {
      var offline = true;
      final store = MemoryTokenStore();
      final api = ApiClient(
        baseUrl: 'http://localhost',
        store: store,
        client: MockClient((request) async {
          if (request.url.path == '/auth/refresh' && offline) {
            throw http.ClientException('offline');
          }
          return http.Response('{}', 401);
        }),
      );
      addTearDown(api.dispose);
      await api.accept(
        AccountSession.fromJson({
          'access_token': 'expired',
          'refresh_token': 'old',
          'user_id': 'user',
          'device_id': 'device',
        }),
      );
      await expectLater(
        api.request('GET', '/sync/pull'),
        throwsA(isA<http.ClientException>()),
      );
      expect(api.session, isNotNull);
      expect(store.values['session'], isNotNull);
      offline = false;
      await expectLater(
        api.request('GET', '/sync/pull'),
        throwsA(isA<ApiException>()),
      );
      expect(api.session, isNull);
      expect(store.values['session'], isNull);
    },
  );
}
