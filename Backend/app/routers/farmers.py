# app/routers/farmers.py
from fastapi import APIRouter, HTTPException
from app.schemas.farmers import FarmerRegister, FarmerLogin, TokenResponse
from app.utils.auth import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/farmers", tags=["Farmers"])

# In-memory "database" for demo purposes
FAKE_DB = {"farmers": []}

@router.post("/register", response_model=TokenResponse)
def register_farmer(farmer: FarmerRegister):
    # Check if farmer already exists
    for f in FAKE_DB["farmers"]:
        if f["phone"] == farmer.phone or f["email"] == farmer.email:
            raise HTTPException(status_code=400, detail="Farmer already exists")
    
    farmer_id = str(len(FAKE_DB["farmers"]) + 1)
    hashed_password = hash_password(farmer.password)
    
    FAKE_DB["farmers"].append({
        "farmer_id": farmer_id,
        "name": farmer.name,
        "phone": farmer.phone,
        "email": farmer.email,
        "password": hashed_password,
        "plots": [p.dict() for p in farmer.plots]
    })
    
    token = create_access_token({"farmer_id": farmer_id})
    
    return {"success": True, "token": token, "farmer_id": farmer_id, "message": "Registration successful"}

@router.post("/login", response_model=TokenResponse)
def login_farmer(login_data: FarmerLogin):
    farmer_record = None
    for f in FAKE_DB["farmers"]:
        if f["phone"] == login_data.phone:
            farmer_record = f
            break
    
    if not farmer_record:
        raise HTTPException(status_code=400, detail="Farmer not found")
    
    if not verify_password(login_data.password, farmer_record["password"]):
        raise HTTPException(status_code=400, detail="Incorrect password")
    
    token = create_access_token({"farmer_id": farmer_record["farmer_id"]})
    
    return {"success": True, "token": token, "farmer_id": farmer_record["farmer_id"], "message": "Login successful"}
