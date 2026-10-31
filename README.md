# AI381 Lab 2 – Customer Churn Prediction API

## Project Overview

This project implements a machine learning API that predicts customer churn using a Logistic Regression model.

The API is built with FastAPI and provides endpoints for checking service health and predicting customer churn.

## Dataset

The project uses `churn_v2.csv`, which contains 1,500 customer records.

Features used by the model:
- `tenure_months`
- `monthly_fee`
- `contract`
- `internet_service`
- `support_calls`

The `customer_id` column is excluded from model training.

## Model Training

The model is trained using a Scikit-learn Logistic Regression pipeline.

To train the model:

```bash
python src/train/train.py
```

The trained model is saved as `model.joblib`.

Model evaluation:
- F1 Score: 0.587
- ROC-AUC: 0.792

## API Endpoints

The API provides the following endpoints:

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | Checks API and model status |
| POST | `/predict` | Predicts customer churn |

Interactive API documentation:

```text
http://localhost:8000/docs
```

## Running Locally

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the API:

```bash
uvicorn src.app.main:app --reload
```

## Example Prediction Request

```json
{
  "tenure_months": 5,
  "monthly_fee": 89.9,
  "contract": "month-to-month",
  "internet_service": "fiber",
  "support_calls": 3
}
```

## Running Tests

Run the automated tests:

```bash
python -m pytest -v
```

The project includes five API tests.

## Docker

Build the Docker image:

```bash
docker build -t churn-api:test .
```

Run the container:

```bash
docker run -d --name churn-api-test -p 8001:8000 churn-api:test
```

Check the health endpoint:

```text
http://localhost:8001/health
```

Open Swagger documentation:

```text
http://localhost:8001/docs
```

## Security Scanning

The Docker image is scanned using Trivy.

The local scan completed with:
- 0 HIGH vulnerabilities
- 0 CRITICAL vulnerabilities

Run the scan:

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 churn-api:test
```

## CI/CD Pipeline

GitHub Actions automates the following steps:

1. Install Python dependencies.
2. Run automated tests.
3. Build the Docker image.
4. Scan the image using Trivy.
5. Publish the Docker image to GitHub Container Registry (GHCR).

## Docker Image

The image is publicly available on GitHub Container Registry:

```text
ghcr.io/hashemkofahi/ai381-lab2-churn-api
```

Pull the current published image:

```bash
docker pull ghcr.io/hashemkofahi/ai381-lab2-churn-api:75987961360d75ce0f328a4ec827701e7ee07a4b
```

## Repository

GitHub Repository:

https://github.com/HashemKofahi/ai381-lab2-churn-api

## Technologies Used

- Python
- Pandas
- Scikit-learn
- FastAPI
- Pytest
- Docker
- GitHub Actions
- Trivy
- GitHub Container Registry (GHCR)
