FROM python:3.12-alpine AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apk update && \
    apk add --no-cache \
        build-base \
        postgresql-client \
        libffi-dev \
    && rm -rf /var/cache/apk/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY . .

###################################################################
FROM python:3.12-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/usr/local/lib/python3.12/site-packages:$PYTHONPATH \
    PATH=/usr/local/bin:$PATH

RUN apk update && \
    apk add --no-cache \
        postgresql-libs \
    && rm -rf /var/cache/apk/*

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /install/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=builder --chown=appuser:appgroup /install/bin/ /usr/local/bin/

COPY --from=builder --chown=appuser:appgroup /app /app

RUN chown -R appuser:appgroup /app

USER appuser

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]