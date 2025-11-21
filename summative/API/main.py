from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import joblib
import numpy as np
import pandas as pd
from fastapi.middleware.cors import CORSMiddleware

# Load the trained model and preprocessing objects
model = joblib.load('best_scoutconnect_model.pkl')
scaler = joblib.load('scaler.pkl')
label_encoders = joblib.load('label_encoders.pkl')
feature_columns = joblib.load('feature_columns.pkl')

app = FastAPI(
    title="ScoutConnect Player Valuation API",
    description="API for predicting African football player market values using FIFA data",
    version="1.0.0",
    docs_url="/docs"
)

# Add CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define input data model with constraints 
class PlayerInput(BaseModel):
    Overall: float = Field(..., ge=50, le=95, description="Overall player rating (50-95)")
    Potential: float = Field(..., ge=60, le=95, description="Potential rating (60-95)")
    Age: int = Field(..., ge=16, le=40, description="Player age (16-40)")
    Height: float = Field(..., ge=160, le=210, description="Height in cm (160-210)")
    Weight: float = Field(..., ge=50, le=100, description="Weight in kg (50-100)")
    technical_skill: float = Field(..., ge=20, le=95, description="Technical skill rating (20-95)")
    physical_ability: float = Field(..., ge=20, le=95, description="Physical ability rating (20-95)")
    attacking_prowess: float = Field(..., ge=20, le=95, description="Attacking prowess rating (20-95)")
    Preferred_Foot: int = Field(..., ge=0, le=1, description="Preferred foot: 0=Left, 1=Right")
    Attacking_Work_Rate: int = Field(..., ge=0, le=2, description="Attacking work rate: 0=Low, 1=Medium, 2=High")
    Defensive_Work_Rate: int = Field(..., ge=0, le=2, description="Defensive work rate: 0=Low, 1=Medium, 2=High")

class PredictionResponse(BaseModel):
    predicted_value: int
    confidence_interval: str
    message: str
    value_category: str
    model_accuracy: str

@app.get("/")
def read_root():
    return {
        "message": "ScoutConnect African Player Valuation API",
        "mission": "Bridge the valuation gap for African football talent using FIFA data analytics",
        "status": "active",
        "model_type": "Random Forest Market Value Prediction",
        "accuracy": "93.7% R² Score",
        "average_error": "±€371,000"
    }

@app.post("/predict", response_model=PredictionResponse)
def predict_player_value(player_data: PlayerInput):
    try:
        # Calculate value_potential_ratio (engineered feature)
        value_potential_ratio = player_data.Potential / player_data.Overall
        
        # Prepare input features - USING ACTUAL COLUMN NAMES FROM YOUR MODEL
        input_data = {
            'Overall': player_data.Overall,
            'Potential': player_data.Potential,
            'Age': player_data.Age,
            'Height(in cm)': player_data.Height,
            'Weight(in kg)': player_data.Weight, 
            'technical_skill': player_data.technical_skill,
            'physical_ability': player_data.physical_ability,
            'attacking_prowess': player_data.attacking_prowess,
            'value_potential_ratio': value_potential_ratio,
            'Preferred Foot': player_data.Preferred_Foot,
            'Attacking Work Rate': player_data.Attacking_Work_Rate, 
            'Defensive Work Rate': player_data.Defensive_Work_Rate
        }
        
        # Create DataFrame
        input_df = pd.DataFrame([input_data])
        
        # Ensure we have all required features in correct order
        missing_features = [col for col in feature_columns if col not in input_df.columns]
        for feature in missing_features:
            input_df[feature] = 0  # Default for any missing engineered features
        
        input_df = input_df[feature_columns]
        
        # Scale features
        input_scaled = scaler.transform(input_df)
        
        # Make prediction
        prediction = model.predict(input_scaled)
        predicted_value = max(0, int(prediction[0]))
        
        # Determine value category based on African market context
        if predicted_value < 1000000:
            value_category = "Local Talent"
        elif predicted_value < 5000000:
            value_category = "Developing Prospect"
        elif predicted_value < 15000000:
            value_category = "African Star"
        elif predicted_value < 30000000:
            value_category = "Continental Elite"
        else:
            value_category = "Global Superstar"
        
        return PredictionResponse(
            predicted_value=predicted_value,
            confidence_interval="±€371,000",  # Based on actual MAE
            message="African player market value prediction successful",
            value_category=value_category,
            model_accuracy="93.7% accurate (R² Score)"
        )
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error making prediction: {str(e)}")

@app.get("/features")
def get_feature_info():
    """Endpoint to show required features and their importance"""
    return {
        "required_features": feature_columns,
        "feature_count": len(feature_columns),
        "top_features": ["Overall", "Potential", "attacking_prowess"],
        "model_info": "Random Forest trained on FIFA African player data"
    }

@app.get("/health")
def health_check():
    return {
        "status": "healthy", 
        "mission": "ScoutConnect African Player Valuation",
        "model_performance": "93.7% R² Score",
        "average_error": "€371,000"
    }

# Example endpoint for testing
@app.get("/example")
def get_example_input():
    """Get example input for testing the API"""
    return {
        "example_player": {
            "Overall": 82,
            "Potential": 88,
            "Age": 22,
            "Height": 185,
            "Weight": 78,
            "technical_skill": 80,
            "physical_ability": 75,
            "attacking_prowess": 85,
            "Preferred_Foot": 1,
            "Attacking_Work_Rate": 2,
            "Defensive_Work_Rate": 1
        },
        "expected_value_range": "€8-12 million"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)