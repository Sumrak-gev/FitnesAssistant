# API

`ApiClient` обращается к серверу из `--dart-define=API_URL=...`.
JSON-запросы авторизуются access JWT; при 401 выполняется одна ротация refresh и один повтор.
Параллельные 401 внутри клиента объединяются в один refresh. Основной и фоновый engine
координируют ротацию через SQLite lease и перечитывают атомарную пару токенов из secure storage.
Ошибка сети не удаляет сессию; отклонённый refresh возвращает пользователя на экран входа.
В release допускается только HTTPS. Тела ошибок не содержат отклонённых паролей.

Рабочие маршруты: `/auth/register|login|refresh|logout`, `/sync/push`, `/sync/pull?since=...`,
`/products?q=...`, `/exercises?q=...`. Полная схема — `/openapi.json` и
`docs/nutrition-openapi.json`. Обновление: из server выполнить
`python -m app.export_nutrition_contract`.
