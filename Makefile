
test:
	cd api && poetry run python manage.py test

build:
	docker-compose build

run:
	docker-compose up -d
