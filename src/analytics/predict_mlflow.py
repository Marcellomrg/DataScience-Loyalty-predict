# %%
import pandas as pd
import sqlalchemy
import mlflow

mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment(experiment_name="Fiel_tmw")

versions = mlflow.search_model_versions(filter_string="name = 'Model_Fiel'")

last_version = max([int(i.version) for i in versions])
last_version 
# %%
# Carregando dados
con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

df = pd.read_sql("SELECT * FROM  abt_fiel",con)
df.head()
# %%
# Carregando meu modelo
model = mlflow.sklearn.load_model(f"models:///Model_Fiel/{last_version}")
# %%
# Realizando a predicao usando meu modelo
predict_proba = model.predict_proba(df[model.feature_names_in_])[:,1]

df["predict"] = predict_proba
df.head()
# %%
