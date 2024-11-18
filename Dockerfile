# Etapa de compilación
FROM node:18 AS builder

# Define el directorio de trabajo
WORKDIR /app

# Copia los archivos de configuración y de bloqueo para aprovechar la caché
COPY package.json pnpm-lock.yaml ./
COPY babel.config.json jest.config.ts jest.preset.js nx.json tsconfig.base.json workspace.json ./

# Copia las carpetas necesarias para instalar las dependencias
COPY apps ./apps
COPY libs ./libs
COPY tools ./tools

# Instala pnpm globalmente y las dependencias del proyecto
RUN npm install -g pnpm && pnpm install

# Compila el proyecto (asegúrate de cambiar `my-app` por el nombre de tu aplicación en `apps`)
RUN pnpm nx build catalog --prod

# Etapa de producción
FROM nginx:stable-alpine

# Copia los archivos estáticos generados en la carpeta de construcción
COPY --from=builder /app/dist/apps/catalog /usr/share/nginx/html

# Expone el puerto 80
EXPOSE 80

# Inicia el servidor Nginx
CMD ["nginx", "-g", "daemon off;"]
