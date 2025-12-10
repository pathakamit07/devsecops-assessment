# ---- Builder Stage ----
FROM node:18-alpine AS builder
WORKDIR /app

# Install build dependencies (only in builder)
RUN apk add --no-cache python3 make g++

# Copy package manifests first for layer caching
COPY package*.json ./

# Use npm ci if lockfile exists, otherwise fallback to npm install
RUN if [ -f package-lock.json ]; then npm ci --only=production; else npm install --only=production; fi

# Copy application code
COPY . .

# ---- Runtime Stage: Alpine (non-root) ----
FROM node:18-alpine AS runtime

# create non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# copy only production artifacts from builder stage
COPY --from=builder /app /app

# ensure ownership for non-root user
RUN chown -R appuser:appgroup /app

# switch to non-root user
USER appuser

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node","server.js"]