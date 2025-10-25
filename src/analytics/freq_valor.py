# %%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
import seaborn as sn
# %%
# Importando minha query
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query


# %%
# Criando minha conexao com meu banco
engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
# %%
query = import_query("freq_valor.sql")
df = pd.read_sql(query,engine)
df
# %%
# Plotando grafico 
plt.title("Freq x Valor")
plt.plot(df["Freq"],df["Valor"],"o")
plt.grid(True)
plt.xlabel("Freq")
plt.ylabel("Valor")
plt.show()
# %%
# Dropando Outlier 
df = df[df["Valor"] < 8000]
df
# %%
from sklearn import cluster
from sklearn import preprocessing

kmean = cluster.KMeans(n_clusters=5
                       ,random_state=42
                       ,max_iter=10000)

# %%
minmax = preprocessing.MinMaxScaler()
X = minmax.fit_transform(df[["Freq","Valor"]])
df_X = pd.DataFrame(X,columns=["normFreq","normValor"])
df_X
# %%
kmean.fit(X)
df["cluster_calc"] = kmean.labels_
df_X["cluster"] = kmean.labels_
# %%
# Grafico com dados nao normalizados ou padronizados
sn.scatterplot(data=df
               ,x= "Freq"
               ,y="Valor"
               ,hue="cluster_calc"
               ,palette="deep")

plt.hlines(y=2000,xmin=0,xmax=20,colors='black')
plt.vlines(x=10,ymin=0,ymax=4000,colors='black')
plt.vlines(x=4,ymin=0,ymax=900,colors='black')
plt.vlines(x=15,ymin=2000,ymax=4000,colors='black')

plt.hlines(y=900,xmin=0,xmax=10,colors='black')
plt.hlines(y=1000,xmin=10,xmax=20,colors='black')


plt.grid(True)

# %%
# Grafico com dados normalizados
sn.scatterplot(data=df
               ,x= "Freq"
               ,y="Valor"
               ,hue="cluster"
               ,palette="deep")

plt.grid(True)

# %%
