#!/bin/bash
# Ingere os arquivos de dados locais no HDFS
set -e

HDFS="hdfs dfs"
DATA_DIR="/data"

echo "=== Ingestão de dados no HDFS ==="

echo "Verificando conexão com NameNode..."
hdfs dfsadmin -report | head -5

echo "Criando estrutura de diretórios no HDFS..."
$HDFS -mkdir -p /data/csv /data/json /data/parquet

echo "Enviando CSV..."
$HDFS -put -f $DATA_DIR/vendas.csv /data/csv/vendas.csv

echo "Enviando JSON..."
$HDFS -put -f $DATA_DIR/vendas.json /data/json/vendas.json

echo "Enviando Parquet..."
$HDFS -put -f $DATA_DIR/vendas.parquet /data/parquet/vendas.parquet

echo ""
echo "=== Arquivos no HDFS ==="
$HDFS -ls -h /data/csv/
$HDFS -ls -h /data/json/
$HDFS -ls -h /data/parquet/

echo ""
echo "=== Status do cluster ==="
hdfs dfsadmin -report | grep -E "^(Name|Datanodes|DFS Used|DFS Remaining)"
