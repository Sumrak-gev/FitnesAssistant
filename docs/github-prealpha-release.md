# GitHub и pre-alpha релиз

## Добавить проект в `main`

Git-репозиторий проекта находится в папке `FitnesAssistant` (там, где лежат `pubspec.yaml` и `.git`). Соседние папки `FitnesAssistant(main)`, `FitnesAssistant(+progres)` и другие копии в этот репозиторий добавлять не нужно.

1. Из корня репозитория проверьте `git status` и просмотрите изменения. Убедитесь, что в коммит не попадут `.env`, пароли, ключи подписи, локальные базы и другие секреты. Текущие изменения `.gitignore` с правилами для `.env`, SQLite и `.venv` нужно включить в PR.
2. Добавьте нужные файлы, создайте коммит и отправьте текущую ветку:

   ```sh
   git add .
   git diff --cached --stat
   git diff --cached
   git commit -m "Prepare offline pre-alpha"
   git push -u origin feature/sync-core
   ```

3. На GitHub откройте Pull Request `feature/sync-core` → `main`. Проверьте diff и проверки CI, затем слейте PR. Не заменяйте `main` принудительным push.

## Выпустить Android pre-alpha

Для этого релиза сервер и PostgreSQL не нужны: начальные функции работают офлайн. Приложение сохраняет часть данных локально в SQLite; это не синхронизированная серверная БД.

1. После слияния PR обновите `version` в `pubspec.yaml`, например на `0.1.0-pre.1+1`, и зафиксируйте коммит.
2. На компьютере с Flutter SDK выполните из корня проекта:

   ```sh
   flutter pub get
   flutter analyze
   flutter test
   flutter build apk --release
   ```

3. Создайте и отправьте тег версии:

   ```sh
   git tag v0.1.0-pre.1
   git push origin v0.1.0-pre.1
   ```

4. На GitHub создайте Release по тегу `v0.1.0-pre.1`, отметьте **Set as a pre-release** и приложите `build/app/outputs/flutter-apk/app-release.apk`. Укажите, что это ранняя тестовая версия и перечислите доступные функции и известные ограничения.

Папка `build/` остаётся локальным результатом сборки и не коммитится; APK прикладывается к GitHub Release отдельно.
