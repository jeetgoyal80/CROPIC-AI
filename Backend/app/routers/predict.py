# app/routers/predict.py
from fastapi import APIRouter, UploadFile, File
import torch
from app.utils.utils import preprocess_image, load_model  # fixed absolute import

router = APIRouter()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load only disease model
disease_model = load_model("app/models/disease_model.pt", device)

# Disease classes
disease_classes = [
    'Pepper__bell___Bacterial_spot', 'Pepper__bell___healthy',
    'Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy',
    'Tomato_Bacterial_spot', 'Tomato_Early_blight', 'Tomato_Late_blight',
    'Tomato_Leaf_Mold', 'Tomato_Septoria_leaf_spot',
    'Tomato_Spider_mites_Two_spotted_spider_mite',
    'Tomato__Target_Spot', 'Tomato__Tomato_YellowLeaf__Curl_Virus',
    'Tomato__Tomato_mosaic_virus', 'Tomato_healthy'
]

# Mapping crop, health, severity, growth based on disease name
def map_disease_info(disease_name):
    disease_lower = disease_name.lower()

    # Determine crop
    if "tomato" in disease_lower:
        crop = "Tomato"
    elif "potato" in disease_lower:
        crop = "Potato"
    elif "pepper" in disease_lower:
        crop = "Pepper"
    else:
        crop = "Unknown"

    # Determine health and severity
    if "healthy" in disease_lower:
        health = "Healthy"
        severity = 0.0
    else:
        health = "Stressed"
        if any(x in disease_lower for x in ["blight", "mold", "spot"]):
            severity = 0.7
        else:
            severity = 0.5

    # Estimate growth stage
    if crop == "Tomato":
        growth_stage = "Flowering"
    elif crop == "Potato":
        growth_stage = "Vegetative"
    elif crop == "Pepper":
        growth_stage = "Vegetative"
    else:
        growth_stage = "Unknown"

    # Clean disease name
    disease_clean = disease_name.replace("_", " ").replace("  ", " ").title()

    # Message
    message = f"{crop} is detected with {disease_clean}. Health status is {health} with severity {severity}."

    return {
        "crop": crop,
        "disease": disease_clean,
        "health": health,
        "severity": severity,
        "growth_stage": growth_stage,
        "message": message
    }

@router.post("/predict/")
async def predict(file: UploadFile = File(...)):
    img_tensor = preprocess_image(file.file).to(device)

    with torch.no_grad():
        # Disease prediction
        d_out = disease_model(img_tensor)
        d_idx = torch.argmax(d_out, dim=1).item()
        d_conf = float(torch.softmax(d_out, dim=1)[0, d_idx])
        d_pred = disease_classes[d_idx]

    # Map additional info
    result = map_disease_info(d_pred)
    result["confidence"] = round(d_conf, 4)

    return result
