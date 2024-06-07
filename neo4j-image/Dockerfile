# Parent image
FROM redhat/ubi8:8.6

LABEL description="Neo4j v5.20.0 for HuBMAP"

# Change to directory that contains the Dockerfile
WORKDIR /usr/src/app

# Copy from host to image
COPY . .

# Reduce the number of layers in image by minimizing the number of separate RUN commands
# 1 - Update the package listings
# 2 - Install wget and OpenJRE 17 (packaged with OpenJDK 17)
# 3 - Download neo4j community server
# 4 - Extract neo4j tarball
# 5 - Rename folder to neo4j
# 6 - Remove the downloaded neo4j tarball
# 7 - Clean all yum cache
RUN yum update -y && \
    yum install -y wget java-17-openjdk && \
    wget http://dist.neo4j.org/neo4j-community-5.20.0-unix.tar.gz && \
    tar -zxvf neo4j-community-5.20.0-unix.tar.gz && \
    mv neo4j-community-5.20.0 neo4j && \
    rm neo4j-community-5.20.0-unix.tar.gz && \
    yum clean all
    
# The EXPOSE instruction informs Docker that the container listens on the specified network ports at runtime. 
# EXPOSE does not make the ports of the container accessible to the host.
EXPOSE 7474 7687

# Start the neo4j server when container spins up
# Use `console` instead of `start` to keep the terminal window stay open
CMD ["/usr/src/app/neo4j/bin/neo4j", "console"]