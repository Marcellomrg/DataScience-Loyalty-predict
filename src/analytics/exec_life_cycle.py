# %%
import pandas as pd
import sqlalchemy
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
dates = [
        "2024-05-01",
        "2024-06-01",
        "2024-07-01",
        "2024-08-01",
        "2024-09-01",
        "2024-10-01",
        "2024-11-01",
        "2024-12-01",
        "2025-01-01",
        "2025-02-01",
        "2025-03-01",
        "2025-04-01",
        "2025-05-01",
        "2025-06-01",
        "2025-07-01",
        "2025-08-01",
        "2025-09-01"
]

for i in dates:

    with engine_analytics.connect() as con:

        con.execute(sqlalchemy.text(f"DELETE FROM life_cycle WHERE dtRef = date('{i}','-1 day')"))
        con.commit()
        
    try:

        print(i)
        format_query = query.format(date=i)
        df = pd.read_sql(format_query,engine_app)
        df.to_sql("life_cycle",engine_analytics,index=False,if_exists='append')
    except Exception as e:
        print(f'Erro na data {i}: {e}')
        break

# %%


