# Dockerfile for Coolify (Building from source instead of ghcr.io)
# Replace `image: ghcr.io/...` with `build: .` in docker-compose if you wish to use this
FROM node:22-alpine AS builder
WORKDIR /app

# Install build‑time dependencies
RUN apk add --no-cache g++ make py3-pip

# Install pnpm globally
RUN npm i -g pnpm@10.6.1

# Copy source files
COPY . .

# Install all dependencies and build the monorepo
RUN pnpm install --frozen-lockfile
RUN pnpm run build

# -----------------------------------------------------------------------------
# Runtime stage
# -----------------------------------------------------------------------------
FROM node:22-alpine AS runtime
WORKDIR /app

# Install runtime dependencies (nginx for reverse‑proxy)
RUN apk add --no-cache nginx

# Create nginx user and set permissions
RUN adduser -D -g 'www' www && \
    mkdir -p /www && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /www

# Copy the entire built application
COPY --from=builder /app .

# Install pm2 globally
RUN npm i -g pnpm@10.6.1 pm2

# Copy nginx configuration
COPY var/docker/nginx.conf /etc/nginx/nginx.conf

EXPOSE 5000

# Start nginx and the PM2 process manager
CMD ["sh", "-c", "nginx && pnpm run pm2"]
