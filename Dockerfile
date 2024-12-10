# Gunakan image Jenkins dengan JDK 17 dan versi Jenkins yang ditentukan sebagai base image
FROM jenkins/jenkins:2.430-jdk21
# Update dan install dependencies
USER root
RUN apt-get update && \
    apt-get install -y lsb-release curl wget unzip tzdata gnupg && \
    # Install Docker CLI
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli

# Set environment variables untuk Maven
ENV MAVEN_VERSION 3.8.6
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG /root/.m2
ENV TZ="Asia/Dhaka"

# Install Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip && \
    unzip apache-maven-${MAVEN_VERSION}-bin.zip -d /usr/share && \
    ln -s /usr/share/apache-maven-${MAVEN_VERSION} ${MAVEN_HOME} && \
    rm apache-maven-${MAVEN_VERSION}-bin.zip

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Create a Maven user and group
RUN groupadd -r maven && useradd -r -g maven -s /sbin/nologin maven && \
    chown -R maven:maven ${MAVEN_HOME}

# Switch to the Maven user
USER jenkins

# Expose Jenkins port
EXPOSE 8080
