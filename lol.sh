#!/bin/sh
# lol.sh
# 
# Description: this script nukes any non-whitelisted UUIDs 
#
# Created by squinn on 6/9/2014

set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
logfile="/private/var/log/lol.log"
date=`date "+%Y-%m-%d"`
whitelist="/private/var/lol/whitelist.txt"
safelist="/private/var/lol/safe.txt"
disklist="/private/var/lol/disklist.txt"
nukelist="/private/var/lol/nukelist.txt"
## Functions
####################################################################################################
## log function
log () {
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logfile	
}

troll() {
	while true; do
	printf "TR"
	for i in {1..64}; do
		printf "OL"
	done
done
}

killStuff () {
	log "unauthorized device connected. time to nuke." && 	log "5" && 	sleep 1 && log "4" && sleep 1 && log "3" && sleep 1 && log "2" && sleep 1 && log "1" && sleep 1 && log "blastoff" && sleep 5
	diskutil list | grep "/" > $disklist
	log "removing safe list from current disks"
	grep -v -f $safelist $disklist > $nukelist
	cat $nukelist | \
	while read list; do
		log "forcing unmount of $list"
		diskutil unmountDisk force $list
		log "say goodnight"
		troll | dd of=$list &
	done
	rm $disklist
	rm $nukelist
}


## Script
####################################################################################################




# pipe system.log and check for new usb mass storage controller connections
tail -fn0 /var/log/system.log | \
	while read line; do
		echo "$line" | grep "USBMSC"
		if [ $? = 0 ]; then # connecting a USB drive triggers the script
			log "USB Mass Storage Controller connected, checking serial number..."
			serial=`echo $line | awk '{print $9}'` # awk out the serial number of the connected drive
			grep -Fxq "$serial" $whitelist
				if [ $? = 0 ]; then
					log "serial number found, device authorized"
				else
					killStuff
				fi


       	fi
	done
