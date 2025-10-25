# schemas/farmers.py
from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional


class Plot(BaseModel):
    plot_no: str = Field(..., example="Plot-001")
    area_in_acres: float = Field(..., example=2.5)
    village: str = Field(..., example="Green Village")
    state: str = Field(..., example="Maharashtra")

class FarmerRegister(BaseModel):
    name: str = Field(..., example="Rahul Kumar")
    phone: str = Field(..., example="9876543210")
    email: EmailStr
    password: str = Field(..., min_length=6)
    plots: List[Plot]

class FarmerLogin(BaseModel):
    phone: str = Field(..., example="9876543210")
    password: str = Field(..., min_length=6)

class TokenResponse(BaseModel):
    success: bool
    token: Optional[str]
    farmer_id: Optional[str]
    message: str
