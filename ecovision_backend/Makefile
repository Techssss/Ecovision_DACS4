.PHONY: help install dev test run migrate clean

help:
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make dev        - Install development dependencies"
	@echo "  make run        - Run development server"
	@echo "  make test       - Run tests"
	@echo "  make migrate    - Run database migrations"
	@echo "  make clean      - Clean cache and temporary files"

install:
	pip install -r requirements.txt

dev:
	pip install -r requirements-dev.txt

run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

test:
	pytest

migrate:
	alembic upgrade head

clean:
	find . -type d -name __pycache__ -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf htmlcov

