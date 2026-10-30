
from pathlib import Path
from typing import Any

import joblib
import pandas as pd
from fastapi import FastAPI
from pydantic import BaseModel, ConfigDict, Field

ROOT = Path(__file__).resolve().parents[2]
MODEL_PATH = ROOT / "model.joblib"

FEATURES = [
    "tenure_months",
    "monthly_fee",
    "contract",
    "internet_service",
    "support_calls",
]

# Load the trained model
model = joblib.load(MODEL_PATH)

app = FastAPI(
    title="AI381 Lab 2 - Churn Prediction API",
    version="1.0.0",
)


class CustomerInput(BaseModel):
    model_config = ConfigDict(extra="forbid")

    tenure_months: int = Field(ge=0, le=120)
    monthly_fee: float = Field(ge=0, le=1000)
    contract: str = Field(min_length=1)
    internet_service: str = Field(min_length=1)
    support_calls: int = Field(ge=0, le=100)


class PredictionResponse(BaseModel):
    churn_probability: float


@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_loaded": model is not None,
    }


@app.post("/predict", response_model=PredictionResponse)
def predict(customer: CustomerInput):
    customer_data: dict[str, Any] = customer.model_dump()

    X = pd.DataFrame(
        [[customer_data[feature] for feature in FEATURES]],
        columns=FEATURES,
    )

    probability = float(model.predict_proba(X)[0, 1])

    return {
        "churn_probability": round(probability, 3)
    }
