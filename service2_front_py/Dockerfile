FROM docker.io/python:3-slim

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    setuptools \
    opentelemetry-distro==0.47b0 \
    opentelemetry-exporter-otlp==0.47b0 \
    -r requirements.txt

RUN opentelemetry-bootstrap --action=install

EXPOSE 5000

ENV OTEL_LOGS_EXPORTER=otlp
ENV OTEL_METRICS_EXPORTER=otlp
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_EXPORTER_OTLP_ENDPOINT=localhost:4317
ENV OTEL_SERVICE_NAME=todoui-flask

CMD ["opentelemetry-instrument", "python", "app.py"]