# Parent image
FROM redhat/ubi8:8.6

LABEL description="Neo4j v5.20.0 for HuBMAP"

# Change to directory that contains the Dockerfile
WORKDIR /usr/src/app

# Copy from host to image
COPY . .

# Reduce the number of layers in image by minimizing the number of separate RUN commands
# Update the package listings
# Install wget and OpenJRE 17 (packaged with OpenJDK 17)
# Download neo4j community server
# Extract neo4j tarball
# Rename folder to neo4j
# Move the APOC core jar to plugins directory
# Download the APOC extended jar
# Move the APOC extended jar to neo4j plugins directory
# Remove the downloaded neo4j tarball
# Clean all yum cache
RUN yum update -y && \
    yum install -y wget java-17-openjdk && \
    wget http://dist.neo4j.org/neo4j-community-5.20.0-unix.tar.gz && \
    tar -zxvf neo4j-community-5.20.0-unix.tar.gz && \
    mv neo4j-community-5.20.0 neo4j && \
    mv neo4j/labs/apoc-5.20.0-core.jar neo4j/plugins && \
    wget https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/5.20.0/apoc-5.20.0-extended.jar && \
    mv apoc-5.20.0-extended.jar neo4j/plugins && \
    rm neo4j-community-5.20.0-unix.tar.gz && \
    yum clean all
    
# The EXPOSE instruction informs Docker that the container listens on the specified network ports at runtime. 
# EXPOSE does not make the ports of the container accessible to the host.
EXPOSE 7474 7687

# Start the neo4j server when container spins up
# Use `console` instead of `start` to keep the terminal window stay open
CMD ["/usr/src/app/neo4j/bin/neo4j", "console"]