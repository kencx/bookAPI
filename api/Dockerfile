FROM python:3.9-alpine3.15

ENV	POETRY_VERSION=1.1.8 \
	POETRY_VIRTUALENVS_CREATE=0 \
	PIP_NO_CACHE_DIR=1 \
	PIP_DISABLE_PIP_VERSION_CHECK=1 \
	PIP_DEFAULT_TIMEOUT=100

RUN apk update \
	&& apk add curl gcc musl-dev openssl-dev libffi-dev nginx
RUN pip3 install "poetry==$POETRY_VERSION"

WORKDIR /app

COPY poetry.lock pyproject.toml /app/
RUN poetry install --no-dev --no-ansi --no-interaction

COPY ./entrypoint.sh /app

RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
