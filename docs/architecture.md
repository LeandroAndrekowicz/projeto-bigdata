# Arquitetura do Ambiente Big Data

## Visão Geral

```
┌─────────────────────────────────────────────────────────┐
│                    HOST (sua máquina)                   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │              Docker Network: bigdata-net          │   │
│  │                   172.20.0.0/24                  │   │
│  │                                                  │   │
│  │  ┌────────────────────────────────────────────┐  │   │
│  │  │         namenode (172.20.0.10)             │  │   │
│  │  │                                            │  │   │
│  │  │   ● HDFS NameNode   (porta 9870)           │  │   │
│  │  │   ● Spark Master    (porta 8080 / 7077)    │  │   │
│  │  │   ● Jupyter         (porta 8888)           │  │   │
│  │  └────────────────────────────────────────────┘  │   │
│  │              │                  │                │   │
│  │   ┌──────────┴───┐    ┌─────────┴──────┐        │   │
│  │   │  datanode-1  │    │  datanode-2    │        │   │
│  │   │ 172.20.0.11  │    │ 172.20.0.12   │        │   │
│  │   │              │    │               │        │   │
│  │   │ ● DataNode   │    │ ● DataNode    │        │   │
│  │   │ ● Spark Wkr  │    │ ● Spark Wkr  │        │   │
│  │   └──────────────┘    └───────────────┘        │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Componentes

| Componente       | Versão | Função                                      |
|-----------------|--------|---------------------------------------------|
| Apache Hadoop    | 3.3.6  | Sistema de arquivos distribuído (HDFS)       |
| Apache Spark     | 3.5.0  | Engine de processamento distribuído          |
| Python / PySpark | 3.10   | Interface de programação para Spark          |
| Jupyter Notebook | latest | Interface interativa para os testes          |
| Docker Compose   | v3.8   | Orquestração dos contêineres                 |

## Fluxo de Dados

```
Dados brutos (CSV/JSON/Parquet)
        │
        ▼
  /data (volume local)
        │
        │  hdfs dfs -put
        ▼
  HDFS /data/csv|json|parquet
        │         (replicação: 2)
        │         blocos distribuídos entre datanode-1 e datanode-2
        │
        │  spark.read.*
        ▼
  Spark RDD / DataFrame
        │
        │  transformações e ações
        ▼
  Resultados (collect / write)
```

## Configurações Importantes

| Parâmetro                  | Valor | Motivo                                   |
|---------------------------|-------|------------------------------------------|
| `dfs.replication`          | 2     | Tolerância a falha de 1 nó               |
| `spark.executor.memory`    | 1g    | Adequado para ambiente local             |
| `spark.task.maxFailures`   | 4     | Permite retry em caso de queda de nó     |
| `spark.executor.cores`     | 1     | 1 core por executor para melhor paralelismo |

## Portas Expostas

| Serviço          | Porta  | URL                          |
|-----------------|--------|------------------------------|
| HDFS NameNode UI | 9870   | http://localhost:9870        |
| Spark Master UI  | 8080   | http://localhost:8080        |
| Jupyter Notebook | 8888   | http://localhost:8888        |
| DataNode-1 UI    | 9864   | http://localhost:9864        |
| DataNode-2 UI    | 9865   | http://localhost:9865        |
