FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_VERSION=3.3.6
ENV SPARK_VERSION=3.5.0
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until \
    && echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99no-check-valid-until \
    && apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    curl \
    ssh \
    rsync \
    python3 \
    python3-pip \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Hadoop
RUN wget -q https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ \
    && mv /opt/hadoop-${HADOOP_VERSION} $HADOOP_HOME \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# Spark
RUN wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz -C /opt/ \
    && mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 $SPARK_HOME \
    && rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Python dependencies
RUN pip3 install pyspark==${SPARK_VERSION} jupyter pandas pyarrow findspark matplotlib

# SSH sem senha (necessário para Hadoop)
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

# Configurações Hadoop
COPY conf/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY conf/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY conf/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
COPY conf/workers $HADOOP_HOME/etc/hadoop/workers

# Configurações Spark
COPY conf/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
COPY conf/spark-env.sh $SPARK_HOME/conf/spark-env.sh

# Scripts de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9870 9000 8080 7077 8888

ENTRYPOINT ["/entrypoint.sh"]
CMD ["namenode"]
