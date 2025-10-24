from fastapi import FastAPI
from .routers import predict   # relative import

app = FastAPI(
    title="Crop Multi-task Prediction API",
    description="Predicts Disease, Severity, and Growth Stage from crop images.",
    version="1.0"
)

app.include_router(predict.router, prefix="/api", tags=["Prediction"])

@app.get("/")
def root():
    return {"message": "API is running!"}
