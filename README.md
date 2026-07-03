# Ronda 1 — Detecta el bug (solución)

## 1. Bugs encontrados en el desafío original

| # | Archivo/comando | Bug | Corrección |
|---|---|---|---|
| 1 | Dockerfile | Una sola etapa, imagen `node:20` completa | Multi-stage: `node:20-alpine` (build) + `nginx-unprivileged` (producción) |
| 2 | Dockerfile | `CMD ["npm","run","dev"]` levanta servidor de desarrollo | `RUN npm run build` + servir `dist/` con Nginx |
| 3 | Dockerfile | No usa Nginx | Etapa 2 basada en `nginxinc/nginx-unprivileged` |
| 4 | Dockerfile | Corre como root | `nginx-unprivileged` corre como usuario no-root por defecto |
| 5 | `docker run -p 80:8080` | El puerto 80 requiere privilegios de root en el host, y el contenedor no escuchaba en 8080 | Se usa `-p 8081:8080` (host:contenedor), sin privilegios |
| 6 | docker-compose.yml | Password en texto plano (`admin123`) | Variable `${DB_PASSWORD}` desde `.env` |
| 7 | docker-compose.yml | `image: postgres` sin versión | `postgres:16-alpine` (versión fija) |
| 8 | docker-compose.yml | Sin volumen → se pierden los datos | Volumen nombrado `db_data` |
| 9 | docker-compose.yml | Puerto 5432 expuesto igual al del host | Se remapea a `5433:5432` |
| 10 | Nombre de BD | `desafío` con tilde, problemático como identificador | Se usa `desafio` sin tilde |

## 2. Cómo levantar todo

```bash
# 1. Configurar la contraseña de la base de datos
cp .env.example .env
# editar .env y poner una contraseña real

# 2. Construir la imagen del frontend
docker build -t desafio:1.0 .

# 3. Levantar todos los servicios (frontend + Postgres)
docker compose up -d --build
```

## 3. Evidencia de cambio de puertos (vs. la ronda original)

| Servicio | Puerto original (ronda) | Puerto corregido (host:contenedor) |
|---|---|---|
| Nginx (frontend) | `80:8080` | **`8081:8080`** |
| PostgreSQL | `5432:5432` | **`5433:5432`** |

Verificar con:

```bash
docker compose ps
# o
docker port desafio-seguro
docker port desafio-db
```

La app quedará disponible en: **http://localhost:8081**
Postgres quedará disponible en el host en el puerto: **5433**

## 4. Base de datos y tabla

La base `desafio` y la tabla `usuarios` con 3 registros de ejemplo se crean
automáticamente al primer arranque gracias a `init.sql` montado en
`docker-entrypoint-initdb.d`.

Para verificar manualmente:

```bash
docker exec -it desafio-db psql -U admin -d desafio -c "SELECT * FROM usuarios;"
```

Si necesitas crearlas a mano (por ejemplo si el volumen ya existía):

```bash
docker exec -it desafio-db psql -U admin -d desafio

-- dentro de psql:
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO usuarios (nombre, email) VALUES
    ('Ana García', 'ana.garcia@example.com'),
    ('Luis Pérez', 'luis.perez@example.com'),
    ('María Torres', 'maria.torres@example.com');
```
