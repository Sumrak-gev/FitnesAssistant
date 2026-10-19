-- Выполняется один раз под суперпользователем postgres (pgAdmin -> Query Tool).
-- Создаёт роль приложения и две базы: dev и test.
-- Замените CHANGE_ME на пароль из server/.env (DATABASE_URL).

CREATE ROLE fitness_app LOGIN PASSWORD 'CHANGE_ME';

CREATE DATABASE fitness_dev  OWNER fitness_app ENCODING 'UTF8';
CREATE DATABASE fitness_test OWNER fitness_app ENCODING 'UTF8';
