# Parent image
FROM centos:7

LABEL description="Neo4j v4.2.5 for HuBMAP"

# Change to directory that contains the Dockerfile
WORKDIR /usr/src/app

# Copy from host to image
COPY . .

# Reduce the number of layers in image by minimizing the number of separate RUN commands
# 1 - Update the package listings
# 2 - Install wget and OpenJRE 11 (packaged with OpenJDK 11)
# 3 - Download neo4j community server
# 4 - Extract neo4j tarball
# 5 - Rename folder to neo4j
# 6 - Download the Apoc 4.2 jar
# 7 - Move the apoc jar to neo4j plugins
# 8 - Remove the downloaded neo4j tarball
# 9 - Clean all yum cache
RUN yum update -y && \
    yum install -y wget java-11-openjdk && \
    wget http://dist.neo4j.org/neo4j-community-4.2.5-unix.tar.gz && \
    tar -zxvf neo4j-community-4.2.5-unix.tar.gz && \
    mv neo4j-community-4.2.5 neo4j && \
    wget https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/4.2.0.2/apoc-4.2.0.2-all.jar && \
    mv apoc-4.2.0.2-all.jar neo4j/plugins && \
    rm neo4j-community-4.2.5-unix.tar.gz && \
    yum clean all
    
# The EXPOSE instruction informs Docker that the container listens on the specified network ports at runtime. 
# EXPOSE does not make the ports of the container accessible to the host.
EXPOSE 7474 7687
