-- Este script corre automáticamente la primera vez que se crea
-- el volumen de datos de Postgres (gracias a docker-entrypoint-initdb.d)

CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO usuarios (nombre, email) VALUES
    ('Ana García',    'ana.garcia@example.com'),
    ('Luis Pérez',    'luis.perez@example.com'),
    ('María Torres',  'maria.torres@example.com');
