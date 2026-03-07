# %%
from flask import Flask,request
import mlflow
import pandas as pd
# MLFLOW
mlflow.set_tracking_uri("http://localhost:5000")
versions = mlflow.search_model_versions(filter_string="name = 'Model_Fiel'")
last_version = max([int(i.version) for i in versions])
model = mlflow.sklearn.load_model(f"models:///Model_Fiel/{last_version}")

# %%
app = Flask(__name__)

@app.route("/health_check")
def hello_world():
    return {"status":"ok"}

@app.route("/predict",methods=['POST'])
def predict():
    try:
        df = pd.DataFrame(request.json)
        X = df[model.feature_names_in_]
        score = model.predict_proba(X)[:,1]
        return {"score":float(score)}
    
    except Exception as err:
        print(err)
        return request.json
  
# %%
