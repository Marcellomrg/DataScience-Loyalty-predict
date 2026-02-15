# %%
import pandas as pd
import sqlalchemy
from sklearn import model_selection
pd.set_option('display.max_rows',500)

# %%
# Criando conexao com meu banco
con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")
con
# %%
# Acessando minha tabela abt_fiel
df = pd.read_sql("abt_fiel",con)
df
# %%
# SEMMA - SAMPLE

# Separando minha base em OOT,Treino e teste

df_oot = df[df['dtRef'] == df["dtRef"].max()].copy()
df_oot

# %%

df_train_test = df[df['dtRef'] < df["dtRef"].max()].copy()
df_train_test
# %%

target = 'flFiel'
features = df_train_test.columns[3:].tolist()

X = df_train_test[features].copy()
y = df_train_test[target].copy()
# %%

X_train,X_test,y_train,y_test = model_selection.train_test_split(X,y,
                                                                 test_size=0.2,
                                                                 random_state=42,
                                                                 stratify=y)



# %%
# SEMMA - EXPLORE

print(f'Quantidade no treino {y_train.shape[0]} com taxa de {100 * y_train.mean():.2f}')
print(f'Quantidade no teste {y_test.shape[0]} com taxa de {100 * y_test.mean():.2f}')

# %%
# Explorando dados Nulos
missing = X_train.columns[X_train.isna().sum() > 0].tolist()
missing

# %%
# Explorando dados categoricos e numericos

cat = X_train.columns[X_train.dtypes == 'object'].tolist()

cat_features = ['DescLifeCycleAtual','DescLifeCycleD28']
# %%
num_features = list(set(features) - set(cat_features))
num_features

# %%
# Construindo um df para analise

df_analise = X_train.copy()
df_analise[target] = y_train.copy()
df_analise

# %%
# Ajeitando dados que vieram no formato errado(object)
df_analise[num_features] = df_analise[num_features].astype(float)
df_analise
# %%
# Fazendo uma analise bivariada 
analise_bivariada = df_analise.groupby(target)[num_features].mean().T
analise_bivariada

# %%
analise_bivariada['ratio'] = (analise_bivariada[1]+ 0.001) / (analise_bivariada[0] + 0.001)
analise_bivariada.sort_values(by='ratio',ascending = False)
# %%
# Removendo features que nao estao ajudando na minha analise 
remove = analise_bivariada[analise_bivariada['ratio'] == 1].index.tolist()
remove

for i in remove:
    features.remove(i)
    num_features.remove(i)
# %%
bivariada_cat = df_analise.groupby('DescLifeCycleAtual')[target].mean()
bivariada_cat
# %%
