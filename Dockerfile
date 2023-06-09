FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y curl dnsutils wget vim

# Install Java 20
RUN apt-get install -y openjdk-17-jdk

#Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Python and required modules
RUN apt-get install -y python3 python3-pip
RUN pip3 install azure-storage-blob azure-identity azure-keyvault-keys snowflake-connector-python

#Set Proxy and No_Proxy
#ENV https_proxy=http://proxy.example.com:8080
#ENV no_proxy=localhost,127.0.0.1,.snowflakecomputing.com

# Add CA certificates
COPY ca-certificates.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Create the /connectors/azure directory
RUN mkdir -p /connectors/azure

# Install Confluent CLI
RUN curl -L --http1.1 https://cnfl.io/cli | sh -s -- -b /usr/local/bin

# Install Confluent Platform
RUN curl -O https://packages.confluent.io/archive/7.3/confluent-7.3.2.tar.gz && \
    tar -xzf confluent-7.3.2.tar.gz && \
    rm confluent-7.3.2.tar.gz && \
    mv confluent-7.3.2 /usr/local/confluent-7.3.2

# Set Confluent environment variables
ENV CONFLUENT_HOME=/usr/local/confluent-7.3.2
ENV PATH=$CONFLUENT_HOME/bin:$PATH

# Set the working directory
WORKDIR /home

EXPOSE 8083

# copy ccloud.properties file, connect-distributed.properties file, jar files (snowflake-jdbc.jar, azure-io.lenses.jar)
# run cmd /usr/local/confluent-7.3.2/bin/connect-distributed /usr/local/confluent-7.3.2/etc/kafka/connect-distributed.properties
# copy private.pem key and snowflake-source.json file at home location and open 2 terminal 1 for kafka connect instance and another for running curl cmd

# Copy necessary files
COPY ccloud.properties /usr/local/confluent-7.3.2/
COPY connect-distributed.properties /usr/local/confluent-7.3.2/etc/kafka/
COPY snowflake-jdbc.jar /usr/local/confluent-7.3.2/share/
COPY azure-io.lenses.jar /usr/local/confluent-7.3.2/share/
COPY private.pem /home/
COPY snowflake-source.json /home/

# Start Kafka Connect and curl in separate terminals
#CMD ["bash", "-c", "/usr/local/confluent-7.3.2/bin/connect-distributed /usr/local/confluent-7.3.2/etc/kafka/connect-distributed.properties & bash"]
CMD ["/bin/bash", "-c", "(/usr/local/confluent-7.3.2/bin/connect-distributed /usr/local/confluent-7.3.2/etc/kafka/connect-distributed.properties &); /bin/bash"]

#Edit the plugin.path and create directory at 