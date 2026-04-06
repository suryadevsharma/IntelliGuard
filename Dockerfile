FROM python:3.10-slim AS builder

WORKDIR /app
ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

COPY requirements-full.txt requirements-dev.txt ./
RUN pip install --upgrade pip && pip install --prefix=/install -r requirements-full.txt

FROM python:3.10-slim AS runtime

WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local
COPY . /app

EXPOSE 7860 8000

ENTRYPOINT ["supervisord", "-c", "/app/supervisord.conf"]

