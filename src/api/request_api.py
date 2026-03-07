# %%
import requests
import sqlalchemy
import pandas as pd
import json

# %%
# CARREGANDO MEUS DADOS DO BANCO
con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")
query = "SELECT * FROM fs_all LIMIT 1"
data = pd.read_sql(query,con=con)
data = data.to_dict()
data
# %%
resp = requests.post("http://localhost:5001/predict",json=data)
resp.json()

# %%
resp = requests.get("http://localhost:5001/health_check")
resp.json()
# %%
