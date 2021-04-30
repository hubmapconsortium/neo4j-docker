# neo4j-docker 4.2.5

All the neo4j(`dev`, `test`, `stage`, and `prod`) versions use the same HuBMAP neo4j image, and the neo4j configuration as well as database files are mounted from the host to the container for data persistence across container restarts.

## Migrate neo4j 3.5.x to 4.2.x

Step 1: Live backup the current neo4j PROD database

Step 2: Remove node properties `doi_suffix_id` and `has_doi`

````
MATCH (n:Entity)
REMOVE n.doi_suffix_id, n.has_doi
RETURN count(n)
````

Step 3: Shut down the neo4j PROD database and do an offline backup

Step 4: Copy 3.5.x database backup to 4.2.5 Neo4j enterprise edition

The `neo4j-admin copy` command comes with the Neo4j Enterprise edition can be used to clean up database inconsistencies, compact stores, and do a migration at the same time.

https://neo4j.com/docs/migration-guide/current/online-backup-copy-database/#tutorial-online-backup-copy-database

````
./neo4j-admin copy --from-path=/private/tmp/3.5.x/hubmap.db --to-database=hubmap
````

Step 5: Move the copied database to the new neo4j PROD docker

Step 6: Pull the hubmap/neo4j-image and start up the PROD container

````
./neo4j-docker.sh prod start
```` 

Step 7: Add the new neo4j PROD EC2 to security group and allow the ports 7474 and 7687

Step 8: Change DNS from Route 53 to point `http://neo4j.hubmapconsortium.org:7474/` to the new instance

Step 9: Initial login and change password (can reuse the old password?) 

## Set container max memory limit

Based on the memory limit on the deployment server, you may need to change the default max memory allocation for the running container specified in the `docker-compose` yaml file shown below. 

````
# By default this `deploy` key only takes effect when deploying to a swarm with docker stack deploy, and is ignored by docker-compose up
# However, we can use the `--compatibility` flag within `docker-compose --compatibility up`
# The `--compatibility` flag will attempt to convert deploy keys in docker-compose v3 to their non-Swarm equivalent
deploy:
  resources:
    limits:
      # Modify this based on the actual VM resource
      memory: 4G
# Allow the JVM to read cgroup limits
# -XX:+UseContainerSupport is enabled by default on linux machines, 
# this feature was introduced in java10 then backported to Java-8u191, the base image comes with OpenJDK(build 1.8.0_232-b09)
# -XX:MaxRAMPercentage (double) is depending on the max memory limit assigned to the contaienr
# When the container has > 1G memory, set -XX:MaxRAMPercentage=75.0 is good (doesn't waste too many resources)
environment:
  - _JAVA_OPTIONS=-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0
````

By default we use `4G` for `dev`, `test`, and `stage` container. The `prod` container has more resurces allocated. And once all the neo4j containers are running, you can verify with:

````
sudo docker stats --all
````

And the output would look like below when we deployed all the three versions of neo4j on the same host machine:

````
CONTAINER ID        NAME                 CPU %               MEM USAGE / LIMIT   MEM %               NET I/O             BLOCK I/O           PIDS
17f3635c031e        hubmap-neo4j-stage   0.72%               748.3MiB / 4GiB     18.27%              14.1kB / 529kB      0B / 327kB          55
e71fa8001aa5        hubmap-neo4j-dev     0.44%               418.2MiB / 4GiB     10.21%              656B / 0B           0B / 331kB          50
2a5177b88ab9        hubmap-neo4j-test    0.48%               899MiB / 4GiB       21.95%              14.7kB / 288kB      0B / 333kB          54
````

And within the container, we also specified the JVM max heap size if 75% of the container's max memory limit via `-XX:MaxRAMPercentage=75.0` with reasonable RAM limits (> 1 GB). By default it's 25% without setting this, and because the JVM uses more memory than just heap, 75% leaves enough free RAM for other processes like a debug shell and doesn't waste too many resources.

And once the container is running, you can shell into the container and verify the max heap size by:

````
java -XX:+PrintFlagsFinal -version | grep HeapSize
````

Or 

````
java -XshowSettings:vm
````

## Data persistence via volume mount

There's an empty directory under each version's sub-directory named `hubmap`, which is the database to be mounted from host to the neo4j container for data persistence.

If you have an exported version of the database, for instance `$NEO4J_HOME/data/databases/graph`. Copy all the files within `graph` to this `hubmap` before starting the container.


## Spin up the neo4j container

We can start the neo4j container by:

````
sudo ./neo4j-docker.sh dev start
````

And to stop the service:

````
sudo ./neo4j-docker.sh dev stop
````

For TEST and STAGE deployment, simply change to:

`sudo ./neo4j-docker.sh test start` and `sudo ./neo4j-docker.sh test stop` for start and stop the neo4j `test` container.

The changes for `test` version include:

* Binding to different ports on the host.
* Run an `init` inside each container that forwards signals and reaps processes.
* Specifying a restart policy like `restart: always` to avoid downtime.

## Update HuBMAP neo4j docker image

All the `dev`, `test`, `stage`, and `prod` versions is based on the same `hubmap/neo4j-image:latest` image. If you need to update the neo4j image, recrerate it with 

````
cd neo4j-image
sudo docker build -t hubmap/neo4j-image:4.2.5 .
````

Then publish it to the DockerHub:

````
sudo docker login
sudo docker push hubmap/neo4j-image:4.2.5
````
