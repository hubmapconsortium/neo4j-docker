#!/bin/bash

echo
echo "==================== Neo4j data backup ===================="

# This function sets DIR to the directory in which this script itself is found.
# Thank you https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself                                                                      
function get_dir_of_this_script () {
    SCRIPT_SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SCRIPT_SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" >/dev/null 2>&1 && pwd )"
        SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
        [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$DIR/$SCRIPT_SOURCE" # if $SCRIPT_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" >/dev/null 2>&1 && pwd )"
    echo $DIR
}

if [[ "$1" != "localhost" && "$1" != "dev" && "$1" != "test" && "$1" != "stage" && "$1" != "prod" ]]; then
    echo "Unknown environment '$1', specify 'localhost', 'dev', 'test', 'stage', or 'prod'"
else
    if [ $# -eq 1 ]; then
        echo "No backup dir supplied as the second argument"
        exit 1
    fi

    if [ ! -d "$2" ]; then
        echo "Backup directory $2 does not exists"
        exit 1
    fi
    
    # Remove the trailing slash if present
    backup_dir=${2%/}

    file_path="$backup_dir/neo4j_$1_data_backup_$(date '+%Y_%m_%d_%H_%M_%S').tar.gz"
    tar -zcvf "$file_path" $( get_dir_of_this_script )/$1/data

    echo
    echo "Saved to $file_path"
fi
