FROM python:3.9-slim-bullseye as python-base

ENV PYTHONUNBUFFERED=1 \
	PYTHONDONTWRITEBYTECODE=1 \
	PIP_NO_CACHE_DIR=0 \
	PIP_DISABLE_PIP_VERSION_CHECK=1 \
	PIP_DEFAULT_TIMEOUT=100 \
	POETRY_VERSION=1.1.13 \
	POETRY_VIRTUALENVS_IN_PROJECT=1 \
	VENV_PATH="/.venv"

ENV PATH="$VENV_PATH/bin:$PATH"
RUN useradd --system --no-create-home --uid 1000 default

FROM python-base as builder-base
RUN apt-get update \
	&& apt-get install -y build-essential

RUN pip install --upgrade pip && \
	pip install poetry==$POETRY_VERSION && \
	poetry --version
RUN python -m venv $VENV_PATH

COPY poetry.lock pyproject.toml ./
RUN poetry install --no-dev --no-ansi --no-interaction

FROM python-base as final
COPY --from=builder-base $VENV_PATH $VENV_PATH
COPY ./kaed /app
WORKDIR /app

COPY ./entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

USER 1000:1000
EXPOSE 8000
CMD ["./entrypoint.sh"]
