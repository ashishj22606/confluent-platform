# FROM ubuntu:latest

# # Install Java 17
# RUN apt-get update && \
#     apt-get install -y openjdk-17-jdk

# # Install Confluent CLI
# RUN apt-get install -y curl && \
#     curl -L --http1.1 https://cnfl.io/cli | sh -s -- -b /usr/local/bin

# # Install Confluent Platform
# # RUN wget -qO - https://packages.confluent.io/deb/6.2/archive.key | apt-key add - && \
# #     add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/6.2 stable main" && \
# #     apt-get update && \
# #     apt-get install -y confluent-platform-2.13

# RUN curl -O http://packages.confluent.io/archive/7.3/confluent-7.3.2.tar.gz
# RUN tar -xzf confluent-7.3.2.tar.gz
# RUN mv confluent-7.3.2 /opt/confluent

# # Install additional utilities
# RUN apt-get install -y dnsutils wget vim

# Set environment variables, if needed
# ENV VARIABLE_NAME=value

# Set entrypoint or default command, if needed
# ENTRYPOINT ["command"]
# CMD ["command"]

# Expose any necessary ports, if needed
# EXPOSE port

# Add any additional configuration files, if needed
# COPY config_file /path/to/container/file

# Set working directory, if needed
# WORKDIR /path/to/working/directory

# Add your application files, if needed
# COPY app_files /path/to/container/file

# Start your application, if needed
# CMD ["command"]

FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y curl dnsutils wget vim

# Install Java 20
RUN apt-get install -y openjdk-17-jdk

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

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
WORKDIR /app

# Add your application files and configuration here

# Start the container
#CMD ["bash"]


# copy ccloud.properties file, connect-distributed.properties file, jar files (snowflake-jdbc.jar, azure-io.lenses.jar)
# run cmd /usr/local/confluent-7.3.2/bin/connect-distributed /usr/local/confluent-7.3.2/etc/kafka/connect-distributed.properties
# copy private.pem key and snowflake-source.json file at home location and open 2 terminal 1 for kafka connect instance and another for running curl cmd

# Copy necessary files
COPY ccloud.properties /usr/local/confluent-7.3.2/
COPY connect-distributed.properties /usr/local/confluent-7.3.2/etc/kafka/
COPY snowflake-jdbc.jar /usr/local/confluent-7.3.2/
COPY azure-io.lenses.jar /usr/local/confluent-7.3.2/
COPY private.pem /root/
COPY snowflake-source.json /root/

# Start Kafka Connect and curl in separate terminals
CMD ["bash", "-c", "/usr/local/confluent-7.3.2/bin/connect-distributed /usr/local/confluent-7.3.2/etc/kafka/connect-distributed.properties & bash"]