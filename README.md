# neo4j-docker

We have three versions of the neo4j: DEV, TEST, and STAGE. 

- DEV version is used for development realted activities with a sample neo4j database. 
- TEST version is used for testing purposes. 
- STAGE for before production deployment. 

And for all versions, the neo4j configuration and graph database are mounted from the host to the container for data persistence across container restarts.

## Set the neo4j password

First you'll need to create a file named `start.sh` based on the `start.sh.example` under the directory of each deployment version. This script sets the neo4j password.

The username for connecting to neo4j (via either neo4j browser or bolt protocol) is "neo4j" (can't be changed) and default password is "1234". To change the neo4j password, go to `dev/start.sh` or `test/start.sh` or `stage/start.sh` and edit the line and replace "1234" with the desired password.

````
/usr/src/app/neo4j/bin/neo4j-admin set-initial-password 1234
````

Note: this line is a shell command so some special characters in the password needs to be taken care of by quoting or backslash-escaping, be careful with that.

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

By default we use `4G` for each container. And once all the neo4j containers are running, you can verify with:

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

## Build docker image and spin up the neo4j container

We'll describe the steps with DEV deployment:

````
sudo chmod +x neo4j-docker.sh
sudo ./neo4j-docker.sh dev build
````

This build creates the neo4k docker image for `dev`. After that, we can start the neo4j container by:

````
sudo ./neo4j-docker.sh dev start
````

And to stop the service:

````
sudo ./neo4j-docker.sh dev stop
````

For TEST and STAGE deployment, simply change to:

`sudo ./neo4j-docker.sh test build` to build the docker image. Then `sudo ./neo4j-docker.sh test start` and `sudo ./neo4j-docker.sh test stop` for start and stop the neo4j `test` container.

The changes for `test` version include:

* Binding to different ports on the host.
* Run an `init` inside each container that forwards signals and reaps processes.
* Specifying a restart policy like `restart: always` to avoid downtime.

## Update base image

Both the `dev`, `test`, and `stage` versions are based on the `hubmap/neo4j-base-image:latest` image. If you need to update the base image, recrerate it with 

````
sudo docker build -t hubmap/neo4j-base-image:latest
````

Then publish it to the DockerHub:

````
sudo docker login
sudo docker push hubmap/neo4j-base-image:latest
````
