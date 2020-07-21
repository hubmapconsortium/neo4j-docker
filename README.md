# neo4j-docker

We have three versions of the neo4j: DEV, TEST, and STAGE. The DEV version is used for development realted activities with a sample neo4j database. The TEST version is used for testing purposes. And the STAGE for before production deployment. And for all versions, the neo4j configuration and graph database are mounted from the host to the container for data persistence across container restarts.

## Set the neo4j password

The username for connecting to neo4j (via either neo4j browser or bolt protocol) is "neo4j" (can't change this) and default password is "1234". To change the neo4j password, go to `dev/start.sh` or `test/start.sh` or `stage/start.sh` and edit the line:

````
/usr/src/app/neo4j/bin/neo4j-admin set-initial-password 1234
````

## Set container max memory limit

Based on the memory limit on the deployment server, you may need to change the default max memory allocation for the running container specified in the `docker-compose` yaml file. By default we use `4G` for each container. And once all the neo4j containers are running, you can verify with:

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
