# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.11.6
FROM python:${PYTHON_VERSION}-slim as base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

COPY . .

# Give user permissions to write to these folders
ADD --chown=appuser --chmod=755 ./log ./log
ADD --chown=appuser --chmod=755 ./logs ./logs
ADD --chown=appuser --chmod=755 ./target ./target

RUN dbt deps

USER appuser

EXPOSE 8080

ARG env
ARG full_refresh=0
ENV FULL_REFRESH=$full_refresh

CMD ["sh", "-c", "if [ \"$FULL_REFRESH\" = \"1\" ]; then dbt run --target $env --full-refresh; else dbt run --target $env; fi"]
