# %%
import pandas as pd
import sqlalchemy
from sklearn import model_selection,tree,ensemble,metrics
from feature_engine import imputation,encoding,selection

pd.set_option('display.max_columns',500)
pd.set_option('display.max_rows',500)

# %%
# Criando conexao com meu banco
con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")
con
# %%
# Acessando minha tabela abt_fiel
df = pd.read_sql("SELECT * FROM abt_fiel",con)
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

# %%
bivariada_cat = df_analise.groupby('DescLifeCycleAtual')[target].mean()
bivariada_cat
# %%
# SEMMA -MODIFY

# Dropando as features que nao ajudam no meu modelo

X_train[num_features] = X_train[num_features].astype(float)
X_train.dtypes

remove = analise_bivariada[analise_bivariada['ratio'] == 1].index.tolist()
remove

drop_features = selection.DropFeatures(features_to_drop=remove)
drop_features

# %%
# IMPUTANDO NAS VARIAVEIS COM MISSING 

missing = X_train.columns[X_train.isna().sum() > 0].tolist()
missing

fill_0 = list(set(missing[6:-1])-set(remove))
fill_0

imputation_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0,
                                                 variables=fill_0)
imputation_0

# %%
# Fazendo imputacao da minha variavel categorica
imputation_cat = imputation.CategoricalImputer(fill_value="Novo Usuario",
                                               variables=['DescLifeCycleD28'])
imputation_cat

# %%
# Imputando numero alto para aqueles usuarios que só vinheram somente em uma live 
imputation_1000 = imputation.ArbitraryNumberImputer(arbitrary_number=1000,
                                                    variables=['AvgintervaloDias',
                                                               'AvgintervaloDiasD28',
                                                               'Freq',
                                                               'AvglifeCycle',
                                                               'ratio',
                                                               'qtdDiasUltiAtividade'])
imputation_1000

# %%
# Tratando as variaveis categoricas atraves do One Hot encoding 
onehot = encoding.OneHotEncoder(variables=cat_features)

# %%
# Modificando meus dados da base treino 
X_train_transform = drop_features.fit_transform(X_train)
X_train_transform = imputation_0.fit_transform(X_train_transform)
X_train_transform = imputation_cat.fit_transform(X_train_transform)
X_train_transform = imputation_1000.fit_transform(X_train_transform)
X_train_transform = onehot.fit_transform(X_train_transform)
X_train_transform
# %%
# Modificando meus dados da base teste
X_test_transform = drop_features.transform(X_test)
X_test_transform = imputation_0.transform(X_test_transform)
X_test_transform = imputation_cat.transform(X_test_transform)
X_test_transform = imputation_1000.transform(X_test_transform)
X_test_transform = onehot.transform(X_test_transform)
X_test_transform
# %%
# Modificando meus dados da base OOT
X_oot_transform = drop_features.transform(df_oot[features])
X_oot_transform = imputation_0.transform(X_oot_transform)
X_oot_transform = imputation_cat.transform(X_oot_transform)
X_oot_transform = imputation_1000.transform(X_oot_transform)
X_oot_transform = onehot.transform(X_oot_transform)
X_oot_transform


# %%
# SEMMA - MODEL
#model = tree.DecisionTreeClassifier(random_state=42,
#                                    min_samples_leaf=50)
model = ensemble.RandomForestClassifier(n_estimators=150,
                                        random_state=42,
                                        min_samples_leaf=200,
                                        n_jobs=-1)
model.fit(X_train_transform,y_train)


# %%
# SEMMA - ASSESS 

y_pred_train = model.predict(X_train_transform)
y_proba_train = model.predict_proba(X_train_transform)[:,1]

y_pred_test = model.predict(X_test_transform)
y_proba_test = model.predict_proba(X_test_transform)[:,1]

y_pred_oot = model.predict(X_oot_transform)
y_proba_oot = model.predict_proba(X_oot_transform)[:,1]

acc_train = metrics.accuracy_score(y_train,y_pred_train)
auc_train = metrics.roc_auc_score(y_train,y_proba_train)

acc_test = metrics.accuracy_score(y_test,y_pred_test)
auc_test = metrics.roc_auc_score(y_test,y_proba_test)

acc_oot = metrics.accuracy_score(df_oot[target],y_pred_oot)
auc_oot = metrics.roc_auc_score(df_oot[target],y_proba_oot)

print(f"Acuracia no treino : {acc_train:.2f}")
print(f"AUC no treino : {auc_train:.2f}")
print(f"Acuracia no teste : {acc_test:.2f}")
print(f"AUC no teste : {auc_test:.2f}")
print(f"Acuracia na OOT : {acc_oot:.2f}")
print(f"AUC na OOT : {auc_oot:.2f}")
# %%
