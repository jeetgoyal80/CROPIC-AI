# utils.py
import torch
from PIL import Image
from torchvision import transforms

def load_model(path, device):
    """
    Load a TorchScript model from path.
    """
    model = torch.jit.load(path, map_location=device)
    model.to(device)
    model.eval()
    return model


def preprocess_image(file):
    """
    Convert uploaded image file to tensor suitable for model.
    """
    img = Image.open(file).convert("RGB")
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485,0.456,0.406], [0.229,0.224,0.225])
    ])
    img_tensor = transform(img).unsqueeze(0)  # Add batch dim
    return img_tensor
