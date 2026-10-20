# Синхронизация

План: Flutter ↔ API ↔ PostgreSQL, локальная очередь изменений, push/pull,
идемпотентные запросы и правила разрешения конфликтов. Сетевой слой и
авторизация — следующие этапы; сейчас данные хранятся только в Drift.

## Как подключить модуль к синхронизации

Общая база уже есть: `lib/core/db/sync_tables.dart` и `sync_writer.dart`.

1. **Таблица.** Добавьте `with SyncMetadata` — получите `userId`, `updatedAt`,
   `deletedAt`, `localRevision`, `serverVersion`. Идентификатор — `text()` с UUID v4.
   Добавьте таблицу в `@DriftDatabase`, увеличьте `schemaVersion` и допишите
   шаг в `onUpgrade` (`createTable` + индексы).
2. **Запись.** В репозитории держите `SyncWriter(database)` и вызывайте внутри
   `database.transaction`: `owner = await sync.userId()`, затем запись сущности
   и `sync.enqueue(...)`. При каждом изменении `localRevision + 1`.
3. **Удаление.** Только мягкое: `deletedAt` и `updatedAt` = сейчас, `localRevision + 1`,
   `enqueue(operation: 'delete')`. Запросы чтения фильтруют `deletedAt.isNull()`.
4. **Имя сущности** в очереди (`entity`) уникально среди модулей, например
   `workout_session`. Модуль читает из очереди только свои сущности
   (см. `nutritionEntities` в `core/api/nutrition_contract.dart`).
5. **Тесты:** запись попадает в очередь, удаление мягкое, чужой владелец недоступен.

Очередь `SyncOutbox` общая для всех модулей. Имена SQL-таблиц `nutrition_users`
и `nutrition_outbox` сохранены ради совместимости со схемой v1/v2.
