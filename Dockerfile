FROM python:3.11.11-slim AS base-image

# POETRY_* are needed to allow the docker image to be run from a non-root users
# without having issues with permissions
ENV PYTHONUNBUFFERED=1 \
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  POETRY_VERSION=2.0.1 \
  POETRY_VIRTUALENVS_PATH=/home/neopiot/app/venv \
  POETRY_CONFIG_DIR=/home/neopiot/app/.config/pypoetry \
  POETRY_DATA_DIR=/home/neopiot/app/.local/share/pypoetry \
  POETRY_CACHE_DIR=/home/neopiot/app/.cache/pypoetry

COPY poetry.lock pyproject.toml ./
RUN pip install "poetry==$POETRY_VERSION"
RUN mkdir -p -m 777 $POETRY_CONFIG_DIR $POETRY_DATA_DIR $POETRY_CACHE_DIR

##
## Intermediate image contains build-essential for installing
## google-cloud-profiler's dependencies
##
FROM base-image AS install-image

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN poetry install --no-interaction --no-ansi --no-cache --no-root --only main
