This `hubmap.db` is the database to be mounted from host to the neo4j container for data persistence.

If you have an exported version of the database, for instance `$NEO4J_HOME/data/databases/graph.db`. Copy all the files within `graph.db` to this `hubmap.db` before starting the container.