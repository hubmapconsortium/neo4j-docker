# neo4j-docker 5.20.0

All the neo4j(`dev`, `test`, and `prod`) deployments use the same HuBMAP neo4j image. The neo4j configuration as well as database files are mounted from the host to the container for data persistence across container restarts.

## Data persistence via volume mount

There's an empty directory under each version's sub-directory named `data`, which is the database to be mounted from host to the neo4j container for data persistence.

If you have an exported version of the database, for instance `$NEO4J_HOME/data`. Copy all the files within `data` to this `data` before starting the container.


## Spin up the neo4j container (shown for DEV)

We can start the neo4j container by:

````
./neo4j-docker.sh dev start
````

And to stop the service:

````
./neo4j-docker.sh dev stop
````

## Copy a database (shown for DEV)

- Stop the running container and remove it
- Replace the whole `dev/data` directory with the new `data` directory containing the new database from either PROD copy or a backup
- Start the container 
- Login with the username and password from the new database copy
- Change the password in Neo4j browser by typing: `:server change-password` then enter the existing password and new one

## Update HuBMAP neo4j docker image

All the `localhost`, `dev`, `test`, and `prod` versions is based on the same `hubmap/neo4j-image` image. To update the neo4j image, recrerate it with 

````
cd neo4j-image
docker build -t hubmap/neo4j-image:5.20.0 .
````

Then publish it to the DockerHub:

````
docker login
docker push hubmap/neo4j-image:5.20.0
````
