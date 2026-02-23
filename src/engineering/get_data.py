# %%
import os
import dotenv
import shutil

dotenv.load_dotenv('../../.env')
from kaggle import api

print(os.environ['KAGGLE_USERNAME'])
print(os.environ['KAGGLE_KEY'])

# %%
datasets = ['teocalvo/teomewhy-loyalty-system',
            'teocalvo/teomewhy-education-platform']

for d in datasets:
    
    dataset_name = d.split("teomewhy-")[-1]
    path = f'../../data/{dataset_name}/database.db'
    api.dataset_download_file(d,'database.db')
    shutil.move('database.db',path)

# %%
