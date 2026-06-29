#!/bin/bash
set -e

service ssh start

echo "Aguardando NameNode ficar disponível em hdfs://namenode:9000..."
until curl -sf http://namenode:9870 > /dev/null 2>&1; do
    echo "  NameNode ainda não disponível, aguardando..."
    sleep 5
done
echo "NameNode disponível. Iniciando DataNode..."

$HADOOP_HOME/bin/hdfs datanode &

echo "Iniciando Spark Worker..."
$SPARK_HOME/sbin/start-worker.sh spark://namenode:7077

wait
