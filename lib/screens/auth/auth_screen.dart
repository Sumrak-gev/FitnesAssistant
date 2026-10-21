import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../data/fitness_repository.dart';
import '../../data/profile_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.api, required this.repository});
  final ApiClient api;
  final ProfileRepository repository;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false, _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await widget.api.authenticate(
        email: _email.text,
        password: _password.text,
        register: _register,
        displayName: _name.text,
      );
      await FitnessRepository(
        widget.repository.database,
      ).bindAccount(session.userId);
      // Migrate pre-v4 local profile into the shared outbox once.
      final records = FitnessRepository(widget.repository.database);
      if (!_register) {
        // An existing account keeps its server goal when signing in on another device.
        await records.setSetting('goalSelected', '1');
      }
      if ((await records.rows('profile')).isEmpty) {
        final profile = await widget.repository.loadProfile();
        if (profile.name.isNotEmpty || profile.weightKg != null) {
          await widget.repository.saveProfile(profile);
        }
      }
      await widget.api.accept(session);
      _password.clear();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error is StateError
              ? error.message.toString()
              : error is ApiException
              ? error.toString()
              : 'Не удалось подключиться. Проверьте интернет и адрес сервера.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Фитнес-помощник')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _register ? 'Создать аккаунт' : 'Войти',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  if (_register)
                    TextFormField(
                      controller: _name,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: 'Отображаемое имя',
                      ),
                    ),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        v != null &&
                            RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(v.trim())
                        ? null
                        : 'Введите email',
                  ),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    autofillHints: [
                      _register
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Пароль (10–128 символов)',
                    ),
                    validator: (v) =>
                        v != null && v.length >= 10 && v.length <= 128
                        ? null
                        : 'От 10 до 128 символов',
                    onFieldSubmitted: (_) {
                      if (!_busy) _submit();
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(
                      _busy
                          ? 'Подождите…'
                          : (_register ? 'Зарегистрироваться' : 'Войти'),
                    ),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _register = !_register;
                            _error = null;
                          }),
                    child: Text(
                      _register ? 'Уже есть аккаунт' : 'Создать аккаунт',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'После первого входа дневник доступен офлайн. Изменения отправятся при подключении к сети.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
