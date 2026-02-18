# %%
import pandas as pd
import sqlalchemy
from sklearn import model_selection,tree,ensemble,metrics,pipeline
from feature_engine import imputation,encoding,selection
import matplotlib.pyplot as plt
import mlflow

mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment(experiment_name="Fiel_tmw")

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
# SEMMA - MODEL
#model = tree.DecisionTreeClassifier(random_state=42,
#                                    min_samples_leaf=50)
model = ensemble.RandomForestClassifier(random_state=42,
                                        n_jobs=-1)

#model = ensemble.AdaBoostClassifier(n_estimators=500
#                                    ,random_state=42
#                                    ,learning_rate=0.01,
#                                    )

params = {
    "n_estimators":[100,150,200,300,400,500],
    "min_samples_leaf":[50,100,150,200,250],
    "max_depth":[2,3,5,10]
}               

grid = model_selection.GridSearchCV(model
                                    ,param_grid=params
                                    ,verbose=3
                                    ,scoring="roc_auc"
                                    ,cv=3)
# %%
with mlflow.start_run():

    mlflow.sklearn.autolog()
    # Criando uma Pipeline para otimizar o treinamento do meu modelo
    model_pipeline = pipeline.Pipeline(steps=[
        ("Remoção de features",drop_features),
        ("Imputação de 0",imputation_0),
        ("Imputação novo Usuário",imputation_cat),
        ("Imputação de 1000",imputation_1000),
        ("Onehot encoding",onehot),
        ("Algoritmo",grid)
    ])
    model_pipeline.fit(X_train,y_train)
    # SEMMA - ASSESS 
    y_pred_train = model_pipeline.predict(X_train)
    y_proba_train = model_pipeline.predict_proba(X_train)[:,1]

    y_pred_test = model_pipeline.predict(X_test)
    y_proba_test = model_pipeline.predict_proba(X_test)[:,1]

    y_pred_oot = model_pipeline.predict(df_oot[features])
    y_proba_oot = model_pipeline.predict_proba(df_oot[features])[:,1]

    acc_train = metrics.accuracy_score(y_train,y_pred_train)
    auc_train = metrics.roc_auc_score(y_train,y_proba_train)

    acc_test = metrics.accuracy_score(y_test,y_pred_test)
    auc_test = metrics.roc_auc_score(y_test,y_proba_test)

    acc_oot = metrics.accuracy_score(df_oot[target],y_pred_oot)
    auc_oot = metrics.roc_auc_score(df_oot[target],y_proba_oot)

    mlflow.log_metrics({
        "acc_train":acc_train,
        "auc_train":auc_train,
        "acc_test":acc_test,
        "auc_test":auc_test,
        "acc_oot":acc_oot,
        "auc_oot":auc_oot,
    })
    roc_train = metrics.roc_curve(y_train,y_proba_train)
    roc_test = metrics.roc_curve(y_test,y_proba_test)
    roc_oot = metrics.roc_curve(df_oot[target],y_proba_oot)

    plt.figure(figsize=(10,4))
    plt.plot(roc_train[0],roc_train[1])
    plt.plot(roc_test[0],roc_test[1])
    plt.plot(roc_oot[0],roc_oot[1])
    plt.xlabel("1 - Especificidade")
    plt.ylabel("Recall")
    plt.title("Curva ROC")
    plt.grid(True)
    plt.legend([f"AUC Treino: {auc_train:.4f}",
                f"AUC Teste: {auc_test:.4f}",
                f"AUC OOT: {auc_oot:.4f}"])
    plt.savefig("curva_roc.png")
    mlflow.log_artifact("curva_roc.png")

    #print(f"Acuracia no treino : {acc_train:.2f}")
    #print(f"AUC no treino : {auc_train:.2f}")
    #print(f"Acuracia no teste : {acc_test:.2f}")
    #print(f"AUC no teste : {auc_test:.2f}")
    #print(f"Acuracia na OOT : {acc_oot:.2f}")
    #print(f"AUC na OOT : {auc_oot:.2f}")
# %%

# Analisando as features que mais estao ajudando no meu modelo
features_names = model_pipeline[:-1].transform(X_train.head(1)).columns.tolist()
features_names

features_importance = model_pipeline["Modelo"].feature_importances_
features_importance

df_feature_importance  = pd.Series(features_importance,index=features_names)
df_feature_importance.head(100).sort_values(ascending=False)
# %%
# Salvando meu Modelo em um arquivo .pkl 
Meu_Modelo = pd.Series(
    {"Model":model_pipeline,
     "Features": X_train.columns.tolist(),
     "AUC Treino ":auc_train,
     "AUC Teste ":auc_test,
     "AUC OOT ":auc_oot,
     }
)
Meu_Modelo.to_pickle("My_Model.pkl")

# %%


# %%
