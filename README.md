# neo4j-docker 4.2.5

All the neo4j(`dev`, `test`, `stage`, and `prod`) deployments use the same HuBMAP neo4j image. The neo4j configuration as well as database files are mounted from the host to the container for data persistence across container restarts.

## Migrate neo4j 3.5.x to 4.2.x on PROD

Step 1: Check and write down the total numbers of nodes, relationship, and node properties in the current neo4j PROD. Also get the total number of nodes with `has_doi` and `doi_suffix_id` respectively.

````
MATCH (n) WHERE n.has_doi IS NOT NULL RETURN COUNT(n)
````

````
MATCH (n) WHERE n.doi_suffix_id IS NOT NULL RETURN COUNT(n)
````

The sum of these two numbers will be verified against the result after migration since we'll be skipping them during copy.

Step 2: Shut down and do an offline backup of the current neo4j PROD database

Step 3: Download the PROD 3.5.x database dump and migrate to 4.2.5 Neo4j enterprise edition locally

The `neo4j-admin copy` command comes with the Neo4j Enterprise edition can be used to clean up database inconsistencies, compact stores, and do a migration at the same time.

https://neo4j.com/docs/migration-guide/current/online-backup-copy-database/#tutorial-online-backup-copy-database

We'll also skip node properties `doi_suffix_id` (Activity, Donor, Sample, Dataset, Collection) and `has_doi` (Collection) during the copy:

````
./neo4j-admin copy --from-path=/private/tmp/3.5.x/hubmap.db --to-database=hubmap --skip-properties=doi_suffix_id,has_doi
````

Verify the output to make sure they match the total number of nodes, relationships, and node properties witht he existing PROD neo4j.

Step 4: Move the converted database to the new neo4j PROD docker

Tar the entire `<neo4j>/data` directory containing the migrated database

````
tar -zcvf data.tar.gz data/
````

And then scp to the PROD VM.

Step 5: Pull the hubmap/neo4j-image and start up the container with data mount

Extract the tar file and copy all the sub-directories to the docker directory `/home/centos/hubmap/neo4j-docker/prod/data`, remember to retain the `README.md`.

````
./neo4j-docker.sh dev|test|stage|prod start
```` 

Step 6: Add the new neo4j PROD EC2 to security group and allow the ports 7474 and 7687

Step 7: Change DNS from Route 53 to point `http://neo4j.hubmapconsortium.org:7474/` to the new PROD instance

Step 8: Initial login with default username/password (neo4j/neo4j) and change password (reuse the old password) 

## Neo4j user and role management

Display current user:

````
SHOW CURRENT USER
````

Create a new user with password:

````
CREATE USER hubmap_neo4j_user
SET PASSWORD "hubmap123"
````

````
SHOW USERS
````

By default, the password will need to be changed, we can alter the user to avoid this:

````
ALTER USER hubmap_neo4j_user
SET PASSWORD CHANGE NOT REQUIRED
````

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
