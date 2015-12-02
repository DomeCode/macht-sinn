#!/bin/bash

##################################
## Script-Name: 	macht-sinn	##
## Type:			Script		##
## Creator:			Crosser		##
## License:	        GPLv3		##
##################################

###
## ~~ Decline and Define Variables ~~ ##
###

# Define, check an load config file
CONF='/etc/machtsinn/machtsinn.conf'

if [ -r "$CONF" ]; then
	. $CONF
else
	echo -e "\033[1mError:\033[0m $CONF is not readable or non existant. Exiting"
	exit 1
fi

# Set macht-sinn's version
SCRIPTVERSION='0.1.2.1'

# Insert first given argument into a variable
ARG="$1"

# Define temporary files
TMPHOSTS="$TMPDIR/hosts.tmp"
TMPAD="$TMPDIR/hosts_ad.tmp"
TMPORIG="$TMPDIR/hosts_orig.tmp"

# Set lock-File location
LCKFILE="/var/lock/machtsinn.lck"

###
## ~~ Working Part ~~ ##
###

gen_lock() {
	touch "$LCKFILE"
}

check_errs(){
  # Parameter 1: Return Code
  # Parameter 2: Display Text
  # Usage: check_errs $? "Error Message"
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # ${1} : ${2}"
    # exit with right error code.
    exit ${1}
  fi
}


gen_temps() {
	if [ -e "$TMPDIR" ]; then
		rm -r "$TMPDIR"
	fi
    
    if [ ! -e "$ADNAME" ]; then
        touch "$ADNAME"
    fi
    
	mkdir "$TMPDIR"
	touch "$TMPHOSTS" "$TMPAD" "$TMPORIG"
	
	grep -vi "^0.0.0.0" "$ADNAME" >> "$TMPORIG"
}

get_prev_linecounts() {
	HOSTORIGCOUNT=$(cat $TMPORIG | wc -l)
	PREVADNAMECOUNT=$(cat $ADNAME | wc -l)
	PREVCOUNT=$(($PREVADNAMECOUNT-$HOSTORIGCOUNT))
}

get_blacklist() {
	for URL in $ADURL
		do
			echo -n "Fetching $URL ..." && wget -T "$GETMAXT" -qO- "$URL" | grep -E '^(127.0.0.1|0.0.0.0)' | sed -ru 's/\ri$//;s/#.*$//;s/^127.0.0.1/'"$ADIP"'/;s/^0.0.0.0/'"$ADIP"':/^.*local$/d;/^.*localdomain$/d;/^.*localhost$/d' >> "$TMPHOSTS" && echo ' Done'
		done
}

gen_new_hostfile() {
	# Copy current hostfile
	cat "$TMPORIG" >> "$TMPAD"

	# Sort AD-List
	sort "$TMPHOSTS" | uniq -u >> "$TMPAD"

	# Overwrite current AD-List
	if [ -e "$ADNAME" ]; then
		rm "$ADNAME"
	fi
	mv "$TMPAD" "$ADNAME"
}

clean_up() {
	if [ -e "$TMPDIR" ]; then
		rm -r "$TMPDIR"
	fi
	
	if [ -e "$LCKFILE" ]; then
		rm "$LCKFILE"
fi
}

get_curr_linecounts() {
	CURADNAMECOUNT=$(cat $ADNAME | wc -l)
	CURCOUNT=$((CURADNAMECOUNT-HOSTORIGCOUNT))
}

showhelp() {
	echo "This script generates a Blacklist for ad- and malwareblocking."
	echo "Since this script needs write-access to $ADNAME, root-privileges are necessary."
	echo "Usage: machtsinn.sh {option}"
	echo "	-g || --generate	Start to generate the Blacklist in $ADNAME"
	echo "	-v || --version		Print the version"
	echo "	-h || --help		Print this message"
}

showerror() {
	echo -e "\033[1mError:\033[0m \"$ARG\" is no valid argument."
}

showversion() {
	echo "macht-sinn version $SCRIPTVERSION, ergibt das Sinn?."
	echo "A true open-source alternative for browser-plugins and other misterious stuff."
}

###
## ~~ Running Part ~~ ##
###

# Check which commmand should get executed and do so
if [ "$ARG" == "--generate" ] || [ "$ARG" == "-g" ]; then
	if [ ! -e "$LCKFILE" ]; then
		if [ "$(id -u)" != "0" ]; then
			echo -e "\033[1mError:\033[0m macht-sinn needs root-privileges to work correctly."
			echo -e "Please use \033[1m machtsinn.sh --help\033[0m for further information."
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
elif [ "$ARG" == "--version" ] || [ "$ARG" == "-v" ]; then
	showversion
elif [ "$ARG" == "--help" ] || [ "$ARG" == "-h" ] || [ -z "$ARG" ]; then
	showhelp
else
	showerror
	showhelp
fi

exit 0
