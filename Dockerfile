# =========================================
# Etapa 1: Builder - compila la app React/Vite
# =========================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copiamos primero solo los manifiestos para aprovechar la cache de capas
COPY package*.json ./
RUN npm ci

# Copiamos el resto del código y compilamos
COPY . .
RUN npm run build
# Vite genera los estáticos en /app/dist

# =========================================
# Etapa 2: Servidor de producción (Nginx sin root)
# =========================================
# Imagen oficial "unprivileged": ya corre como usuario no-root
# y escucha en el puerto 8080 (no en el 80, que requiere privilegios)
FROM nginxinc/nginx-unprivileged:alpine AS production

# Copiamos config personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos únicamente el build final generado en la etapa anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# El usuario no-root (nginx) y el puerto no privilegiado (8080)
# ya vienen configurados por la imagen base
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
