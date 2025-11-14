# %%
import pandas as pd
import sqlalchemy
import datetime
from tqdm import tqdm

# %%
# Importando query
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    
    return query

query = import_query("life_cycle.sql")
print(query)
# %%
# Criando conexao com os database
engine_app = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")

engine_analytics = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

# %%
# INGESTAO DE DADOS 


def ingest_dates(start,stop):
    dates = []
    while start <= stop :
        dates.append(start)
        dt_start = datetime.datetime.strptime(start,"%Y-%m-%d") + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start,"%Y-%m-%d")
    return dates 

dates = ingest_dates("2025-03-01","2025-09-01")


for i in tqdm(dates):

    with engine_analytics.connect() as con:
        try:
            con.execute(sqlalchemy.text(f"DELETE FROM life_cycle WHERE dtRef = date('{i}','-1 day')"))
            con.commit()

        except Exception as e:
            print(e)

    print(i)
    format_query = query.format(date=i)
    df = pd.read_sql(format_query,engine_app)
    df.to_sql("life_cycle",engine_analytics,index=False,if_exists='append')
    

# %%


