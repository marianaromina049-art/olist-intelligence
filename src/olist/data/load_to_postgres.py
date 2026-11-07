import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine, text

# Conexión a la base de datos PostgreSQL en Docker
engine = create_engine("postgresql+psycopg2://ds:ds_pass@localhost:5432/olist")

# Ruta donde están tus archivos CSV en tu proyecto
RAW = Path("data/raw")

# Crear el esquema 'raw' dentro de la base de datos
with engine.begin() as con:
    con.execute(text("CREATE SCHEMA IF NOT EXISTS raw"))

# Iterar sobre cada archivo CSV y cargarlo a la base de datos automáticamente
for csv in sorted(RAW.glob("*.csv")):
    # Limpiar el nombre del archivo para usarlo como nombre de tabla
    table = csv.stem.replace("olist_", "").replace("_dataset", "")
    df = pd.read_csv(csv)
    
    # Subir a Postgres por bloques (chunksize) para optimizar memoria
    df.to_sql(table, engine, schema="raw", if_exists="replace", index=False, chunksize=50_000)
    print(f"Tabla creada o actualizada: {table:35s} con {len(df):>9,} filas")