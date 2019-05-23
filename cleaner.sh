#!/bin/bash

source ./functions.sh

TIME=$(date +"%s")
DELETE_DAY=1
DELETE_HOURS=0
DELETE_MINUTES=0
DELETE_SECONDS=0

DELETE_TOTAL_TIME=$(( $DELETE_DAY * 86400 + $DELETE_HOURS * 3600 + $DELETE_MINUTES * 60 + $DELETE_SECONDS ))

function timestamp_to_be_deleted () {
	filter_timestamp "<=" $(( $TIME - $DELETE_TOTAL_TIME ))
}

function clear_timestamp () {
	timestamp_to_be_deleted | while read timestamp; do delete_per_timestamp $timestamp; done
}

echo "TIMESTAMP GOING TO DELETE:"
timestamp_to_be_deleted

clear_timestamp
echo "Cleared..."

exit 0

# from timestamp to date
#date --date @1537463096

