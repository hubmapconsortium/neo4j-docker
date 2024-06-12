#!/bin/bash

if [[ "$1" != "localhost" && "$1" != "dev" && "$1" != "test" && "$1" != "prod" ]]; then
    echo "Unknown environment '$1', specify 'localhost', 'dev', 'test', or 'prod'"
else
    if [[ "$2" != "start" && "$2" != "stop" ]]; then
        echo "Unknown command '$2', specify 'start' or 'stop' as the second argument"
    else
        if [ "$2" = "start" ]; then
            docker compose -p hubmap-neo4j-docker-$1 -f docker-compose.$1.yml up -d
        elif [ "$2" = "stop" ]; then
            docker compose -p hubmap-neo4j-docker-$1 -f docker-compose.$1.yml stop
        fi
    fi
fi
