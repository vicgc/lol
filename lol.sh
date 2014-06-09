#!/bin/sh
# lol.sh
# 
# Description: this script nukes any non-whitelisted UUIDs 
#
# Created by andrewws on 06/13/13.

# set -x	# DEBUG. Display commands and their arguments as they are executed
# set -v	# VERBOSE. Display shell input lines as they are read.
# set -n	# EVALUATE. Check syntax of the script but dont execute

## Variables
####################################################################################################
logfile="/private/var/log/lol.log"
date=`date "+%Y-%m-%d"`
whitelist="/private/var/lol/whitelist.txt"
safelist="/private/var/lol/safe.txt"
bsdlist="/private/var/lol/bsdlist.txt"
## Functions
####################################################################################################
## log function
log () {
	echo $1
	echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $logfile	
}

popUp () {
	/usr/bin/osascript <<-EOF
    tell application "System Events"
        activate
        display dialog "You've connected an unauthorized USB drive! This action will be reported!"
    end tell
EOF
}

findBSD() {
	log "matching serial $1 to BSD name, please wait..."
	sleep 10
	system_profiler SPUSBDataType > $bsdlist
	bsd=`cat $bsdlist | grep -A9 $1 | tail -n 1 | awk -F "BSD Name: " '{print $2}'`
	rm $bsdlist
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
	log "time to nuke." && 	log "5" && 	sleep 1 && log "4" && sleep 1 && log "3" && sleep 1 && log "2" && sleep 1 && log "1" && sleep 1 && log "blastoff" && sleep 5
	log "forcing unmount of $1"
	forceUnmount "/dev/$bsd"
	grep -Fxq "$1" $safelist
	if [ $? = 0 ]; then
		log "Device in safe list. not killing"
	else
		log "say goodnight"
		troll | dd of=$1 &
	fi


}


forceUnmount() {
	log "forcing unmount"
	diskutil unmountDisk force $1
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
					findBSD $serial
					log "serial $serial is /dev/$bsd"
				else
					log "unauthorized usb device detected serial $serial"
					popUp &
					findBSD $serial
					forceUnmount "/dev/$bsd"
					log "unathorized serial $serial at /dev/$bsd"
					
					# killStuff "/dev/$bsd"

				fi


       	fi
	done
