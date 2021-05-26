#!/bin/bash

echo
echo "==================== Neo4j data backup ===================="

if [[ "$1" != "localhost" && "$1" != "dev" && "$1" != "test" && "$1" != "stage" && "$1" != "prod" ]]; then
    echo "Unknown environment '$1', specify 'localhost', 'dev', 'test', 'stage', or 'prod'"
else
	# Create the backup dir if not exist
	mkdir -p ../neo4j_data_backup

	file_path="../neo4j_data_backup/neo4j_$1_data_backup_$(date '+%Y_%m_%d_%H_%M_%S').tar.gz"

    tar -zcvf $file_path $1/data

    echo
    echo "Saved to $file_path"
fi
