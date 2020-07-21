#!/bin/bash

if [[ "$1" != "dev" && "$1" != "test" && "$1" != "stage" ]]; then
	echo "Unknown build environment '$1', specify 'dev', 'test', or 'stage'"
else
	if [[ "$2" != "build" && "$2" != "start" && "$2" != "stop" ]]; then
		echo "Unknown command '$2', specify 'build' or 'start' or 'stop' as the second argument"
	else
        if [ "$2" = "build" ]; then
			docker-compose -f docker-compose.$1.yml build
	    elif [ "$2" = "start" ]; then
	    	# The `--compatibility` flag will attempt to convert deploy keys (memory limit in our case)
	    	# in docker-compose v3 to their non-Swarm equivalent
			docker-compose -p hubmap-neo4j-docker-$1 -f docker-compose.$1.yml --compatibility up -d
		elif [ "$2" = "stop" ]; then
			docker-compose -p hubmap-neo4j-docker-$1 -f docker-compose.$1.yml stop
	    fi
    fi
fi
