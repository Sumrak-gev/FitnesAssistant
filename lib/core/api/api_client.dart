import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../auth/token_store.dart';

class ApiException implements Exception {
  ApiException(this.status, this.detail);
  final int status;
  final Map<String, dynamic> detail;
  @override
  String toString() => switch (status) {
    401 => 'Сессия истекла. Войдите снова.',
    409 => 'Данные изменились на другом устройстве или аккаунт уже существует.',
    422 => 'Проверьте введённые данные. Пароль: 10–128 символов.',
    429 => 'Слишком много попыток. Подождите минуту.',
    _ => 'Сервер недоступен. Изменения сохранены на устройстве.',
  };
}

class AccountSession {
  AccountSession.fromJson(Map<String, dynamic> data)
    : access = data['access_token'] as String,
      refresh = data['refresh_token'] as String,
      userId = data['user_id'] as String,
      deviceId = data['device_id'] as String,
      localId =
          data['local_session_id'] as String? ??
          const Uuid().v5(
            Namespace.url.value,
            'fitness-session:${data['refresh_token']}',
          );
  final String access, refresh, userId, deviceId, localId;
  Map<String, dynamic> toJson() => {
    'access_token': access,
    'refresh_token': refresh,
    'user_id': userId,
    'device_id': deviceId,
    'local_session_id': localId,
  };
}

class ApiClient extends ChangeNotifier {
  ApiClient({
    http.Client? client,
    TokenStore? store,
    String? baseUrl,
    this.refreshGuard,
  }) : _client = client ?? http.Client(),
       _store = store ?? SecureTokenStore(),
       baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_URL',
             defaultValue: kDebugMode ? 'http://10.0.2.2:8000' : '',
           );
  final http.Client _client;
  final TokenStore _store;
  final String baseUrl;
  final Future<void> Function(Future<void> Function())? refreshGuard;
  AccountSession? session;
  bool restored = false;
  Future<void>? _refreshing;

  Future<void> restore() async {
    try {
      final raw = await _store.read('session');
      if (raw != null) {
        session = AccountSession.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        if (await _store.read('blocked_session') == session!.localId) {
          session = null;
        }
      }
    } on FormatException {
      await _store.delete('session');
    } finally {
      restored = true;
      notifyListeners();
    }
  }

  Future<AccountSession> authenticate({
    required String email,
    required String password,
    required bool register,
    String displayName = '',
  }) async {
    var installation = await _store.read('installation');
    if (installation == null) {
      installation = const Uuid().v4();
      await _store.write('installation', installation);
    }
    final device = const Uuid().v5(installation, email.trim().toLowerCase());
    final result =
        await _send('POST', '/auth/${register ? 'register' : 'login'}', {
          'email': email.trim(),
          'password': password,
          'device_id': device,
          'device_name': 'Android',
          if (register) 'display_name': displayName.trim(),
        });
    return AccountSession.fromJson({
      ...result as Map<String, dynamic>,
      'device_id': device,
    });
  }

  Future<void> _guard(Future<void> Function() action) async {
    final guard = refreshGuard;
    if (guard != null) {
      await guard(action);
    } else {
      await action();
    }
  }

  Future<void> accept(AccountSession value) => _guard(() => _persist(value));

  Future<void> _persist(AccountSession value) async {
    // Persist both rotated tokens as one secure-storage item before exposing them.
    await _store.write('session', jsonEncode(value.toJson()));
    session = value;
    notifyListeners();
  }

  Future<void> logout() async {
    final old = session;
    if (old == null) return;
    // This durable marker prevents a response from an older background engine
    // from restoring a session after logout, even if the process is then killed.
    await _store.write('blocked_session', old.localId);
    await _store.delete('session');
    session = null;
    notifyListeners();
    try {
      await _guard(() async {
        var latest = old;
        final raw = await _store.read('session');
        if (raw != null) {
          final stored = AccountSession.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
          if (stored.localId == old.localId) {
            latest = stored;
            await _store.delete('session');
          }
        }
        await _send('POST', '/auth/logout', {
          'refresh_token': latest.refresh,
          'device_id': latest.deviceId,
        });
      });
    } catch (_) {
      // Offline logout clears local credentials; next login revokes device sessions.
    }
  }

  Future<dynamic> request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final before = session;
    if (before == null) throw ApiException(401, {});
    await _checkLogout(before);
    try {
      return await _send(method, path, body, before.access);
    } on ApiException catch (error) {
      if (error.status != 401) rethrow;
      if (session?.access == before.access) {
        final future = _refreshing ??= _refresh();
        try {
          await future;
        } finally {
          if (identical(_refreshing, future)) _refreshing = null;
        }
      }
      if (session == null) throw ApiException(401, {});
      return _send(method, path, body, session!.access);
    }
  }

  Future<void> _refresh() async {
    await _guard(_refreshLocked);
  }

  Future<void> _checkLogout(AccountSession value) async {
    if (await _store.read('blocked_session') == value.localId) {
      if (session?.localId == value.localId) {
        session = null;
        notifyListeners();
      }
      throw ApiException(401, {});
    }
  }

  Future<void> _refreshLocked() async {
    final before = session;
    if (before == null) throw ApiException(401, {});
    await _checkLogout(before);
    final raw = await _store.read('session');
    if (raw == null) {
      session = null;
      notifyListeners();
      throw ApiException(401, {});
    }
    final stored = AccountSession.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    if (stored.userId != before.userId || stored.deviceId != before.deviceId) {
      throw ApiException(401, {});
    }
    if (stored.refresh != before.refresh || stored.access != before.access) {
      session = stored;
      notifyListeners();
      return;
    }
    try {
      final result = await _send('POST', '/auth/refresh', {
        'refresh_token': before.refresh,
        'device_id': before.deviceId,
      });
      if (session != before) return;
      await _checkLogout(before);
      await _persist(
        AccountSession.fromJson({
          ...result as Map<String, dynamic>,
          'device_id': before.deviceId,
          'local_session_id': before.localId,
        }),
      );
    } on ApiException catch (error) {
      if (error.status == 401 && session == before) {
        await _store.delete('session');
        session = null;
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<dynamic> _send(
    String method,
    String path,
    Map<String, dynamic>? body, [
    String? token,
  ]) async {
    final base = Uri.tryParse(baseUrl);
    if (base == null ||
        !base.hasAuthority ||
        (!kDebugMode && base.scheme != 'https') ||
        !['http', 'https'].contains(base.scheme)) {
      throw StateError(
        'Сервер приложения не настроен. Обратитесь к разработчику.',
      );
    }
    final request = http.Request(
      method,
      Uri.parse('${baseUrl.replaceFirst(RegExp(r"/+$"), "")}$path'),
    );
    request.headers['Content-Type'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(
      await _client.send(request).timeout(const Duration(seconds: 20)),
    ).timeout(const Duration(seconds: 20));
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        decoded = null;
      }
    }
    if (response.statusCode >= 400) {
      final detail = decoded is Map ? decoded['detail'] : null;
      throw ApiException(
        response.statusCode,
        detail is Map<String, dynamic> ? detail : {},
      );
    }
    return decoded;
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
