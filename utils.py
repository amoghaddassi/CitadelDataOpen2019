import pandas as pd
import os

DATA_DIR = "./data"
DATAPATHS = ["{}/dataset_{}.csv".format(DATA_DIR, i) for i in range(1, 9) if os.path.isfile("{}/dataset_{}.csv".format(DATA_DIR, i))]


def import_datatable(i):
    df = pd.read_csv(DATAPATHS[i-1])
    return df

def clean_datatable_1(df):
    codes = df["energy_code"]

