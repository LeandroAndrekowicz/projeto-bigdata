"""
Gera datasets de exemplo nos formatos CSV, JSON e Parquet
para ingestão no HDFS.
"""
import os
import json
import random
import csv
from datetime import datetime, timedelta

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

OUTPUT_DIR = "/data"
NUM_ROWS = 500_000

CATEGORIAS = ["Eletrônicos", "Roupas", "Alimentos", "Livros", "Esportes"]
REGIOES = ["Sul", "Sudeste", "Norte", "Nordeste", "Centro-Oeste"]

random.seed(42)

def gerar_registro(i):
    data_base = datetime(2023, 1, 1)
    data = data_base + timedelta(days=random.randint(0, 730))
    return {
        "id": i,
        "produto": f"Produto_{random.randint(1, 1000):04d}",
        "categoria": random.choice(CATEGORIAS),
        "regiao": random.choice(REGIOES),
        "quantidade": random.randint(1, 100),
        "preco_unitario": round(random.uniform(5.0, 500.0), 2),
        "total": 0.0,
        "data_venda": data.strftime("%Y-%m-%d"),
        "desconto": round(random.uniform(0, 0.3), 2),
    }

print(f"Gerando {NUM_ROWS:,} registros...")
registros = [gerar_registro(i) for i in range(NUM_ROWS)]
for r in registros:
    r["total"] = round(r["quantidade"] * r["preco_unitario"] * (1 - r["desconto"]), 2)

# CSV
csv_path = os.path.join(OUTPUT_DIR, "vendas.csv")
print(f"Escrevendo CSV -> {csv_path}")
with open(csv_path, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=registros[0].keys())
    writer.writeheader()
    writer.writerows(registros)

# JSON (lines)
json_path = os.path.join(OUTPUT_DIR, "vendas.json")
print(f"Escrevendo JSON -> {json_path}")
with open(json_path, "w", encoding="utf-8") as f:
    for r in registros:
        f.write(json.dumps(r, ensure_ascii=False) + "\n")

# Parquet
parquet_path = os.path.join(OUTPUT_DIR, "vendas.parquet")
print(f"Escrevendo Parquet -> {parquet_path}")
df = pd.DataFrame(registros)
df["data_venda"] = pd.to_datetime(df["data_venda"])
table = pa.Table.from_pandas(df)
pq.write_table(table, parquet_path, compression="snappy")

print("\nArquivos gerados com sucesso:")
for nome in ["vendas.csv", "vendas.json", "vendas.parquet"]:
    caminho = os.path.join(OUTPUT_DIR, nome)
    tamanho = os.path.getsize(caminho) / (1024 * 1024)
    print(f"  {nome}: {tamanho:.1f} MB")
