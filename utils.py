import pandas as pd
import os

DATA_DIR = "./data"
DATAPATHS = ["{}/dataset_{}.csv".format(DATA_DIR, i) for i in range(1, 9) if os.path.isfile("{}/dataset_{}.csv".format(DATA_DIR, i))]


def import_datatable(i):
    df = pd.read_csv(DATAPATHS[i-1])
    return df

def clean_datatable_1(df):
    codes = df["energy_code"]

def split_energy_code(code):
	source = code[:2]
	sector = code[2:4]
	value_unit = code[4]
	return source, sector, value_unit

def parse_dataset1(df):
	energy_code_col = df["energy_code"]
	sources = []
	sectors = []
	value_units = []
	for code in energy_code_col:
		source, sector, value_unit = split_energy_code(code)
		sources.append(source)
		sectors.append(sector)
		value_units.append(value_unit)

	df["energy_source"] = sources
	df["sector"] = sectors
	df["value_unit"] = value_units
	return df
