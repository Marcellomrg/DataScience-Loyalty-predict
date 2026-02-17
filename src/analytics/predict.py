# %%
import pandas as pd 
import sqlalchemy

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %%
# Carregando dados
df = pd.read_sql("SELECT * FROM abt_fiel",con=con)
df.head()
# %%
# Carregando Meu Modelo
Model = pd.read_pickle("My_Model.pkl")
Model
# %%
# Realizando o predict usando meu modelo
predict_proba = Model['Model'].predict_proba(df[Model['Features']])[:,1]
predict_proba

# %%
# Adicionando a probabilidade de cada usuario ser fiel
df['predict'] = predict_proba
df.head()
# %%
