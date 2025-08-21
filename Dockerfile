# Multi-stage build for security and efficiency
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application code
COPY . .

# Build application (if needed)
RUN npm run build || true

# Production stage
FROM node:18-alpine AS production

# Create non-root user
RUN addgroup -g 1001 -S djinn && \
    adduser -S -D -H -u 1001 -s /sbin/nologin -G djinn djinn

# Create app directory with proper permissions
WORKDIR /app
RUN chown djinn:djinn /app

# Copy built application from builder stage
COPY --from=builder --chown=djinn:djinn /app/node_modules ./node_modules
COPY --from=builder --chown=djinn:djinn /app/dist ./dist
COPY --from=builder --chown=djinn:djinn /app/package*.json ./

# Create required directories
RUN mkdir -p /app/data /app/logs && \
    chown -R djinn:djinn /app

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

# Switch to non-root user
USER djinn

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node healthcheck.js || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "dist/index.js"]