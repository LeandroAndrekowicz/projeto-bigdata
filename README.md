# Ambiente Big Data Local — Hadoop + Spark + Docker

Projeto acadêmico de ambiente Big Data distribuído com HDFS e Apache Spark, orquestrado via Docker Compose com 1 nó mestre e 2 workers.

## Requisitos

- Docker >= 24.0
- Docker Compose >= 2.20
- 8 GB RAM disponível
- 10 GB espaço em disco

## Estrutura

```
projeto-bigdata/
├── docker/
│   ├── docker-compose.yml      # Orquestração dos 3 nós
│   ├── namenode/               # Imagem do nó mestre (HDFS + Spark Master + Jupyter)
│   └── datanode/               # Imagem dos workers (HDFS DataNode + Spark Worker)
├── data/                       # Datasets gerados (CSV, JSON, Parquet)
├── notebooks/
│   ├── 01_ingest_data.ipynb    # Ingestão no HDFS e verificação
│   ├── 02_benchmark_nodes.ipynb # Benchmark: impacto do nº de workers
│   └── 03_resilience_test.ipynb # Teste de resiliência com queda de nó
├── scripts/
│   ├── generate_data.py        # Geração de 500k registros de vendas
│   └── ingest_hdfs.sh          # Script shell de ingestão
└── docs/
    └── architecture.md         # Arquitetura detalhada
```

## Como Executar

### 1. Build e inicialização

```bash
cd docker
docker compose build      # ~10-15 min no primeiro build
docker compose up -d
```

### 2. Verificar status

```bash
docker compose ps
docker logs namenode --tail 30
```

### 3. Gerar e ingerir dados

```bash
# Dentro do container namenode
docker exec namenode python3 /scripts/generate_data.py
docker exec namenode bash /scripts/ingest_hdfs.sh
```

### 4. Acessar o Jupyter

Abra [http://localhost:8888](http://localhost:8888) e execute os notebooks na ordem:

| Notebook | O que faz |
|----------|-----------|
| `01_ingest_data.ipynb` | Gera dados, envia ao HDFS, lê nos 3 formatos |
| `02_benchmark_nodes.ipynb` | Mede tempo de processamento com 1 e 2 workers |
| `03_resilience_test.ipynb` | Derruba um nó durante job Spark em execução |

## Testes

### Benchmark de nós

```bash
# Rodada com 2 workers (padrão)
# Execute notebook 02

# Parar um worker
docker stop datanode-2

# Rodada com 1 worker
# Execute notebook 02 novamente

# Restaurar
docker start datanode-2
```

### Teste de resiliência

```bash
# Execute notebook 03
# Em outro terminal, durante a execução:
docker stop datanode-2

# O Spark deve completar os jobs usando apenas datanode-1
# O HDFS mantém os dados (replicação fator 2)
```

## Interfaces Web

| Interface | URL |
|-----------|-----|
| HDFS NameNode | http://localhost:9870 |
| Spark Master | http://localhost:8080 |
| Jupyter Notebook | http://localhost:8888 |
| DataNode-1 | http://localhost:9864 |
| DataNode-2 | http://localhost:9865 |

## Resultados Esperados

- **Benchmark:** Parquet ~2-5x mais rápido que CSV para queries analíticas
- **Escalabilidade:** 2 workers ~1.5-2x mais rápido que 1 worker
- **Resiliência:** Jobs completam com 1 nó desde que `dfs.replication=2`

## Encerrar o ambiente

```bash
cd docker
docker compose down          # Para os containers
docker compose down -v       # Para e remove volumes
```

## Arquitetura

Ver [docs/architecture.md](docs/architecture.md) para diagrama detalhado.
