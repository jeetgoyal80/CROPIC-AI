from fastapi import APIRouter, UploadFile, File
import torch
from app.utils import preprocess_image, load_model

router = APIRouter()

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ----------------------------
# Load TorchScript models once
# ----------------------------
disease_model = load_model(
    r"C:\Users\jeetg\Downloads\CROPIC-AI\Backend\app\models\disease_model.pt",
    device
)
# Uncomment these when you have the other models
# severity_model = load_model(r"C:\Users\jeetg\Downloads\CROPIC-AI\Backend\app\models\severity_model.pt", device)
# growth_model = load_model(r"C:\Users\jeetg\Downloads\CROPIC-AI\Backend\app\models\growth_model.pt", device)

# ----------------------------
# Class labels
# ----------------------------
disease_classes = [
    'Pepper__bell___Bacterial_spot', 'Pepper__bell___healthy',
    'Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy',
    'Tomato_Bacterial_spot', 'Tomato_Early_blight', 'Tomato_Late_blight',
    'Tomato_Leaf_Mold', 'Tomato_Septoria_leaf_spot',
    'Tomato_Spider_mites_Two_spotted_spider_mite',
    'Tomato__Target_Spot', 'Tomato__Tomato_YellowLeaf__Curl_Virus',
    'Tomato__Tomato_mosaic_virus', 'Tomato_healthy'
]

# severity_classes = ['Healthy', 'Mild', 'Moderate', 'Severe']
# growth_classes = ['Seedling', 'Vegetative', 'Flowering', 'Mature']

# ----------------------------
# Prediction endpoint
# ----------------------------
@router.post("/predict/")
async def predict(file: UploadFile = File(...)):
    # Preprocess image
    img_tensor = preprocess_image(file.file).to(device)

    with torch.no_grad():
        # Disease prediction
        d_out = disease_model(img_tensor)
        d_pred = disease_classes[torch.argmax(d_out, dim=1).item()]
        d_conf = float(torch.softmax(d_out, dim=1).max())

        # Uncomment when models are ready
        # severity prediction
        # s_out = severity_model(img_tensor)
        # s_pred = severity_classes[torch.argmax(s_out, dim=1).item()]
        # s_conf = float(torch.softmax(s_out, dim=1).max())

        # growth stage prediction
        # g_out = growth_model(img_tensor)
        # g_pred = growth_classes[torch.argmax(g_out, dim=1).item()]
        # g_conf = float(torch.softmax(g_out, dim=1).max())

    return {
        "disease": {"label": d_pred, "confidence": round(d_conf, 4)},
        # "severity": {"label": s_pred, "confidence": round(s_conf, 4)},
        # "growth_stage": {"label": g_pred, "confidence": round(g_conf, 4)}
    }
