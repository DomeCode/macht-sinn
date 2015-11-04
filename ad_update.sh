#!/bin/bash

##################################
## Programm-Name: 	AD_Update	##
## Creator:			Crosser		##
## License:	        GPLv3		##
##################################

###
## ~~ Decline and Define Variables ~~ ##
###

# Set AD_Updates version
SCRIPTVERSION='0.1'

# Insert the given argument into a variable
ARG="$1"

# Set the lock-File location
LCKFILE="/tmp/ad_update.lck"

# Define URL 
ADURL='http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext
http://someonewhocares.org/hosts/hosts
http://www.malwaredomainlist.com/hostslist/hosts.txt
http://winhelp2002.mvps.org/hosts.txt
http://hosts-file.net/download/hosts.txt
http://hosts-file.net/hphosts-partial.txt
http://hostsfile.mine.nu/Hosts'

# Define the AD-List Name
ADNAME='/etc/hosts'

# Define a temp. Host-File
TMPHOSTS='/tmp/hosts.tmp'
TMPAD='/tmp/hosts_ad.tmp'
TMPORIG='/tmp/hosts_orig.tmp'

###
## ~~ Working Part ~~ ##
###

gen_lock() {
	touch $LCKFILE
}

gen_temps() {
	if [ -e "$TMPHOSTS" ]; then
		rm -f $TMPHOSTS
	fi

	if [ -e "$TMPAD" ]; then
		rm -f $TMPAD
	fi

	if [ -e "$TMPORIG" ]; then
		rm -f $TMPORIG
	fi

	touch $TMPHOSTS
	touch $TMPAD
	touch $TMPORIG
	
	grep -vi "^0.0.0.0" $ADNAME >> $TMPORIG
}

get_prev_linecounts() {
	HOSTORIGCOUNT=$(cat $TMPORIG | wc -l)
	PREVADNAMECOUNT=$(cat $ADNAME | wc -l)
	PREVCOUNT=$(($PREVADNAMECOUNT-$HOSTORIGCOUNT))
}

get_blacklist() {
	for i in $ADURL
		do
			echo -n "Fetching $i ..." && wget -qO - $i | grep -E '^(127.0.0.1|0.0.0.0)' | sed 's/\r$//;s/#.*$//;s/^127.0.0.1/0.0.0.0/;/^.*local$/d;/^.*localdomain$/d;/^.*localhost$/d' >> $TMPHOSTS && echo ' Done'
		done
}

gen_new_hostfile() {
	# Copy the current hostfile
	cat $TMPORIG >> $TMPAD

	# Sort the AD-List
	sort $TMPHOSTS | uniq -u >> $TMPAD

	# Overwrite the current AD-List
	if [ -e "$ADNAME" ]; then
		rm -f $ADNAME
	fi
	mv $TMPAD $ADNAME
}

clean_up() {
	if [ -e "$TMPHOSTS" ]; then
		rm -f $TMPHOSTS
	fi

	if [ -e "$TMPAD" ]; then
		rm -f $TMPAD
	fi
	
	if [ -e "$TMPORIG" ]; then
		rm -f $TMPORIG
	fi
	
	if [ -e "$LCKFILE" ]; then
		rm -f $LCKFILE
fi
}

get_curr_linecounts() {
	CURADNAMECOUNT=$(cat $ADNAME | wc -l)
	CURCOUNT=$((CURADNAMECOUNT-HOSTORIGCOUNT))
}

showhelp() {
	echo "This script generates a Blacklist for ad- and malwareblocking."
	echo "Since this script needs write-access to $ADNAME, root-privileges are necessary."
	echo "Usage: ad_update.sh [option]"
	echo "	-c || --client		Start to generate the Blacklists in $ADNAME"
	#echo "	-r || --router		Start to generate the Blacklists in $ADNAME.deny and restart dnsmasq"
	echo "	-v || --version		Print the version"
	echo "	-h || --help		Print this message"
}

showerror() {
	echo -e "\033[1mError:\033[0m \"$ARG\" is no valid argument."
}

showversion() {
	echo "AD_Update version $SCRIPTVERSION, where the ADs stop."
	echo "A true open-source alternative for browser-plugins and other misterious stuff."
}

###
## ~~ Running Part ~~ ##
###

# Check which commmand should get executed and do so
if [ "$ARG" == "--client" ] || [ "$ARG" == "-c" ]; then
	if [ ! -e "$LCKFILE" ]; then
		if [ "$(id -u)" != "0" ]; then
			echo -e "\033[1mError:\033[0m AD_Update needs root-privileges to work correctly."
			echo -e "Please use \033[1msudo ad_update.sh --help\033[0m for further information."
			exit 55
		else
			gen_lock
			gen_temps
			get_prev_linecounts
			get_blacklist
			gen_new_hostfile
			get_curr_linecounts
			clean_up
			echo "Now blocking $CURCOUNT Domains. Previously $PREVCOUNT."
		fi
	else
		echo -e "\033[1mError:\033[0m Lockfile $LCKFILE existant since $(date -r $LCKFILE +%F,T). \033[1mExiting\033[0m"
	fi
#elif [ "$ARG" == "--router" ] || [ "$ARG" == "-r" ]; then
#	echo
#	/etc/init.d/dnsmasq reload
elif [ "$ARG" == "--version" ] || [ "$ARG" == "-v" ]; then
	showversion
elif [ "$ARG" == "--help" ] || [ "$ARG" == "-h" ] || [ -z "$ARG" ]; then
	showhelp
else
	showerror
	showhelp
fi

exit 0
