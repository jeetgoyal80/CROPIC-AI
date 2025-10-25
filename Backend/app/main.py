# app/main.py
from fastapi import FastAPI
from app.routers import predict, farmers  # fixed absolute import

app = FastAPI(
    title="Crop Multi-task Prediction API",
    description="Predicts Disease, Severity, and Growth Stage from crop images.",
    version="1.0"
)

# Prediction routes
app.include_router(predict.router, prefix="/api", tags=["Prediction"])

# Farmer routes
app.include_router(farmers.router, prefix="/api/farmers", tags=["Farmers"])

@app.get("/")
def root():
    return {"message": "API is running!"}
