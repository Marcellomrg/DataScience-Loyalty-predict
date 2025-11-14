# %%
import pandas as pd
import sqlalchemy
import datetime
from tqdm import tqdm
import argparse

# %%
# Importando query
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    
    return query

# %%
# INGESTAO DE DADOS 

def ingest_dates(start,stop):
    dates = []
    while start <= stop :
        dates.append(start)
        dt_start = datetime.datetime.strptime(start,"%Y-%m-%d") + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start,"%Y-%m-%d")
        
    return dates 

def exec_query(dt_start,dt_stop,table,db_origin,db_target):

    # Criando conexao com os database
    engine_app = sqlalchemy.create_engine(f"sqlite:///../../data/{db_origin}/database.db")
    engine_analytics = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")

    query = import_query(f"{table}.sql")
    dates = ingest_dates(dt_start,dt_stop)

    for i in tqdm(dates):

        with engine_analytics.connect() as con:
            try:
                con.execute(sqlalchemy.text(f"DELETE FROM {table} WHERE dtRef = date('{i}','-1 day')"))
                con.commit()

            except Exception as e:
                print(e)

        print(i)
        format_query = query.format(date=i)
        df = pd.read_sql(format_query,engine_app)
        df.to_sql(f"{table}",engine_analytics,index=False,if_exists='append')
    
# %%

def main():

    parser = argparse.ArgumentParser()
    stop = datetime.datetime.now().strftime("%Y-%M-%d")

    parser.add_argument("--start",type=str,default="2024-03-01")
    parser.add_argument("--stop",type=str,default=stop)
    parser.add_argument("--table",type=str,help="Tabela que vai ser processada com o mesmo nome do arquivo")
    parser.add_argument("--db_origin",choices=['loyalty-system','education-plataform'],default='loyalty-system')
    parser.add_argument("--db_target",choices=['analytics'],default='analytics')

    args = parser.parse_args()
    
    exec_query(args.start,args.stop,args.table,args.db_origin,args.db_target)



if __name__ == '__main__':
    main()

