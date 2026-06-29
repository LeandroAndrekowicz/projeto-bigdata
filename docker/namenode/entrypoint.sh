#!/bin/bash
set -e

service ssh start

# Formatar NameNode apenas na primeira execução
if [ ! -d "/hadoop/dfs/name/current" ]; then
    echo "Formatando NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
fi

echo "Iniciando HDFS NameNode..."
$HADOOP_HOME/bin/hdfs namenode &

# Aguarda NameNode subir
echo "Aguardando NameNode ficar disponível..."
until curl -sf http://localhost:9870 > /dev/null 2>&1; do
    sleep 3
done
echo "NameNode disponível."

# Cria diretórios no HDFS
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /data/csv /data/json /data/parquet /spark-logs || true
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /data /spark-logs || true

echo "Iniciando Spark Master..."
$SPARK_HOME/sbin/start-master.sh

echo "Iniciando Jupyter Notebook..."
jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --notebook-dir=/notebooks &

echo "Cluster iniciado. Acesse:"
echo "  HDFS UI:    http://localhost:9870"
echo "  Spark UI:   http://localhost:8080"
echo "  Jupyter:    http://localhost:8888"

wait
