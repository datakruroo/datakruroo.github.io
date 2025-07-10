from fastapi import FastAPI, Request
import tensorflow as tf
import numpy as np

app = FastAPI()

# โหลดโมเดล
model = tf.keras.models.load_model("final_model.keras")

@app.post("/predict")
async def predict(request: Request):
    data = await request.json()
    input_data = np.array(data["input"]).reshape(1, -1)  # แปลง input เป็น array 2 มิติ
    prediction = model.predict(input_data)
    return {"prediction": prediction.tolist()}
