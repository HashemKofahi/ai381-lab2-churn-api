
# Stage 1: Builder
FROM python:3.11-alpine AS builder

WORKDIR /build

RUN apk add --no-cache build-base linux-headers

COPY requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt \
    && rm -rf /opt/venv/lib/python3.11/site-packages/pip \
    && rm -rf /opt/venv/lib/python3.11/site-packages/pip-*.dist-info \
    && rm -rf /opt/venv/lib/python3.11/site-packages/setuptools \
    && rm -rf /opt/venv/lib/python3.11/site-packages/setuptools-*.dist-info \
    && rm -rf /opt/venv/lib/python3.11/site-packages/wheel \
    && rm -rf /opt/venv/lib/python3.11/site-packages/wheel-*.dist-info \
    && rm -f /opt/venv/bin/pip*

# Stage 2: Production
FROM python:3.11-alpine

RUN apk upgrade --no-cache \
    && apk add --no-cache libgomp libstdc++ \
    && python -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    && rm -rf /usr/local/lib/python3.11/site-packages/pip \
    && rm -rf /usr/local/lib/python3.11/site-packages/pip-*.dist-info \
    && adduser -D appuser

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv

COPY src/ ./src/
COPY model.joblib .

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')"

CMD ["uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
