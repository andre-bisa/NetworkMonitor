#!/bin/bash

source ./functions.sh
TIME=$(date +"%s")

readedLine=
readedCommand=
menuOpened=
arrayMenus=( "show" "show:ip" "show:date" "delete" )

### SYNTAX: checkExistsMenu menuName
function checkExistsMenu () {
	for menu in "${arrayMenus[@]}"; do
		if [ "$1" = "$menu" ]; then
			return 0;
		fi
	done
	return 1 
}

arrayOpenMenus=()
### SYNTAX: openMenu menuName
function openMenu() {
	if [ "$#" != 1 ] ; then
		echo "Error on opening menu..."
		exit 1
	fi
	if checkExistsMenu "$1" ; then
		menuOpened="$1"
		return 0
	else
		echo "Menu not found."
		#menu_list
		return 1
	fi
}

function isMenu () {
	return $(checkExistsMenu "$1")
}

function closeMenu () {
	menuOpened=${menuOpened%`echo "$menuOpened" | rev | cut -d ":" -f1 | rev`}
	menuOpened=${menuOpened%:}
	echo "Now opened menu: $menuOpened"
}

function menuList () {
	echo -e "Menus available:"
	for menu in "${arrayMenus[@]}"; do
		if [[ "$menu"* = "$menuOpened"* && "$menu" != "$menuOpened" ]] ; then
			echo -e "\t\t" ${menu#"$menuOpened":} | grep -v ":"
		fi
	done
}

function printMenu () {
	OIFS="$IFS"
	IFS=':'
	local arg=($menuOpened)
	if test ${#arg} -gt 0; then
		echo -n "( "
	fi
	for menu in "${arg[@]}"
	do
	  echo -n "$menu "
	done
	if test ${#arg} -gt 0; then
		echo -n ")"
	fi
	IFS="$OIFS"
}

function readLine () {
	printMenu
	echo -n " > "
	read readedCommand
	readedLine="$readedCommand"
	if test ${#menuOpened} -gt 0; then
		readedLine="$menuOpened:$readedLine"
	fi
}

function executeCommand () {
	case "$menuOpened" in 
		"show:ip")
		executeShowIp $@
		#echo "Ho letto:" $@
		;;
		
		"show:date")
		echo "Data, ho letto:" $@
		;;
	esac
}

### SYNTAX: executeShowIp [ip] [mac]
function executeShowIp () {
	if [ "$#" == 0 ] ; then
		echo "Commands available:"
		return
	fi
	
	case "$1" in
		"all")
		find_all_ip | sort -V | uniq
		;;
		
		*)
		find_all_ip_mac | egrep '^'"$1"'[^0-9]' | sort -V | uniq
		echo -n -e "Last access:\t"
		find_all_ip_date | egrep '^'"$1"'[^0-9]' | tail -n 1 | cut -d' ' -f2-
		;;
	esac
	
}

while true
do
	#clear
	
	menuList
	readLine
	
	if [[ "$readedCommand" = "exit" ]] ; then
		closeMenu
	elif isMenu "$readedLine"; then
		openMenu "$readedLine"
	else
		executeCommand $readedCommand
	fi
	
done

exit 0

menuList
menuOpened="show"
menuList


exit 0

function general_usage () {
	echo -e "Menu allowed:"
	echo -e "\tshow"
	echo -e "\tdelete"
}

function general_menu () {
	general_usage
	
	case read_line in 
		show)
			show_menu $@
			;;
		*)
			echo "Menu not found."
			general_usage
			;;
	esac
}

function show_menu () {
	menu="show"
	if [ $# -le 0 ]; then
		show_usage
	else
		case "$MENU" in
			ip)
			show_ip_menu
			;;
		*)
			echo "Menu not found."
			show_usage
			;;
		esac
	fi
}

function show_usage () {
	echo -e "show ip <IP>\tShows informations about an IP (date online, if is online, etc.)"
}

function show_menu () {
	
}




#ldapsearch -x -b "dc=amm,dc=nodomain" -s sub -LLL '(timestamp>=153744366)' | grep 'timestamp:' | awk -F': ' '{print $2}' | while read T ; do ldapsearch -x -b "timestamp=$T,dc=amm,dc=nodomain" -s one -LLL ; done



echo "Last scan IPs:"
filter_timestamp "<=" $(( $TIME - 15 * 60 ))

general_menu

exit 0

#ldapsearch -x -b "dc=amm,dc=nodomain" -s sub -LLL
echo "IP:"
find_all_ip

echo
echo "IP MAC:"
find_all_ip_mac


echo
echo "IP TIMESTAMP:"
find_all_ip_timestamp

echo
echo "IP DATE:"
#find_all_ip_date
find_all_ip_date_ordered_per_date

#join_per_timestamp $1

exit 0

delete_per_ip_timestamp $(filter_ip "192.168.43.182")

delete_all

exit 0

filter_timestamp '>=' 1 | while read T
do
	join_per_timestamp $T
done

