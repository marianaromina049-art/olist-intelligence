.PHONY: setup lint test api dash db mlflow
setup: ; pip install -r requirements.txt
lint: ; ruff check .
test: ; pytest -q
db: ; docker compose up -d db
api: ; uvicorn app.main:app --reload
dash: ; streamlit run dashboard/app.py
mlflow: ; mlflow ui --port 5000
