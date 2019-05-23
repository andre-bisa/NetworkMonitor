#!/bin/bash

# from timestamp to date
#date --date @1537463096

function find_all () {
	ldapsearch -x -b "dc=amm,dc=nodomain" -s sub -LLL
}

### SYNTAX: filter_timestamp operation value
function filter_timestamp () {
	ldapsearch -x -b "dc=amm,dc=nodomain" -s sub -LLL "(timestamp$1$2)" | grep 'timestamp:' | awk -F': ' '{print $2}'
}

### SYNTAX: filter_ip ip
function filter_ip () {
	ldapsearch -x -b "dc=amm,dc=nodomain" -s sub -LLL "(ip=$1)" | grep 'ip=' | awk -F'=' '{
		split($2,ip,",");
		split($3,timestamp,",");
		print ip[1] " " timestamp[1];
	}'
}

### SYNTAX: mac_from_ip_timestamp ip timestamp
function mac_from_ip_timestamp () {
	mac=$(ldapsearch -x -b "dc=amm,dc=nodomain" -s sub -LLL "(ip=$1)" | grep "mac:" | cut -d " " -f2 | sort | uniq)
	if [ ${#mac} -gt 0 ]; then
		echo "$1 $mac"
	else
		echo "$1"
	fi
}

### SYNTAX: join_per_timestamp timestamp
function join_per_timestamp () {
	ldapsearch -x -b "timestamp=$1,dc=amm,dc=nodomain" -s one -LLL
}

### SYNTAX: delete_per_timestamp timestamp
function delete_per_timestamp () {
	ldapdelete -rx -D "cn=admin,dc=nodomain" -w admin "timestamp=$1,dc=amm,dc=nodomain"
}

### SYNTAX: delete_per_ip_timestamp ip timestamp
function delete_per_ip_timestamp () {
	ldapdelete -rx -D "cn=admin,dc=nodomain" -w admin "ip=$1,timestamp=$2,dc=amm,dc=nodomain"
}

### SYNTAX: delete_per_ip ip
function delete_per_ip () {
	filter_ip "$1" | while read -r line; do delete_per_ip_timestamp $line; done
}

function delete_all () {
	ldapdelete -rx -D "cn=admin,dc=nodomain" -w admin "dc=amm,dc=nodomain"
}


##### FUNZIONI AVANZATE #####

function find_all_ip () {
	find_all | grep "ip:" | cut -d" " -f2 | sort | uniq
}

function find_all_ip_timestamp () {
	find_all_ip | while read IP; do filter_ip $IP; done
}

function find_all_ip_mac () {
	find_all_ip_timestamp | while read -r line; do
		mac_from_ip_timestamp $line
	done | sort | uniq
}

function find_all_ip_date () {
	find_all_ip_timestamp | while read -r line ; do
		#echo "$line" | cut -d " " -f1
		local timestamp=`echo "$line" | cut -d " " -f2`
		echo $(echo "$line" | cut -d " " -f1) $(date --date "@$timestamp")
		#date --date "@$timestamp"
		#date --date @1537463096
	done
}

function find_all_ip_date_ordered_per_date () {
	local timestamp_old=0
	find_all_ip_timestamp | while read -r line ; do
		echo $(echo "$line" | cut -d " " -f2) $(echo "$line" | cut -d " " -f1)
	done | sort | uniq | while read -r line ; do
		local timestamp=`echo "$line" | cut -d " " -f1`
		if [ $timestamp != $timestamp_old ]; then
			echo
			echo -n $(date --date "@$timestamp")
			timestamp_old=$timestamp
		else
			echo -n -e "\t\t\t"
		fi
		echo -n -e "\t" $(echo "$line" | cut -d " " -f2)
		echo
		#date --date "@$timestamp"
		#date --date @1537463096
	done
}
