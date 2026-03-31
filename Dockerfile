# Star Office UI - Dockerfile
# Multi-stage build for minimal image size

FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies for Pillow
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY backend/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ─── Production stage ───────────────────────────────────────────
FROM python:3.11-slim

# Runtime deps for Pillow & general
RUN apt-get update && apt-get install -y --no-install-recommends \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copy application
COPY backend/ /app/backend/
COPY frontend/ /app/frontend/
COPY *.json /app/
COPY *.md /app/
COPY *.py /app/
COPY scripts/ /app/scripts/

# Expose default port
EXPOSE 19000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:19000/health')" || exit 1

# Run
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=19000
CMD ["python", "backend/app.py"]
