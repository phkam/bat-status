#! /bin/sh

# Checks Battery status and displays
# warnings via notify-send
#
#
# The battery capacity is read from /sys/class/power_supply/BAT*/capacity
# For every battery the current capacity is taken and a warning notification
# is displayed if the average capacity sinks below the $WARN or $CRIT treshold
#
# Returncodes
# 10: notify-send not found
# 20: Unrecognized commandline option encountered
# 30: Tested value is not an integer
# 31: Tested value is below the allowed range
# 32: Tested value is above the allowed range


CHK="/sys/class/power_supply"

# warning and critical treshold
WARN="20"
CRIT="15"

# script internal warning or critical trigger/switch
WARNING="0"
CRITICAL="0"

# urgency level processed by notify-send (low, normal, critical)
# is set by warning/critical trigger
LEVEL=""

SLEEP="30"

# Whether the script was called from a system job or not (-s option)
SYSTEM="0"

check_int () {
	## Check whether passed argument is an integer (unsigned)
	# =~ check for regular expression; works only with [[ ]]
	[[ ! ${1} =~ ^[0-9]+$ ]] && echo "Value of ${2} must be an integer." && exit 30
}

check_range () {
	## Check if the value is between 1 and 100. You may change this range, if you like.
	## expects for $1 the passed value to check
	##         for $2 the name of the commandline switch this value belongs to.

	[[ ${1} -lt   1 ]] && echo "Value for ${2} must be greater than 0." && exit 31
	[[ ${1} -gt 100 ]] && echo "Value for ${2} must be less or equal 100." && exit 32
}

display_help () {
	echo A sensible help and usage needs to be written.
	echo For now please refer to the comments in the script.
}

while getopts shw:c:t: OPTION; do
	case $OPTION in
		h) display_help ;;
		s) SYSTEM="1" ;;
		w) WARN=$OPTARG
		   check_int ${WARN} -w
		   check_range ${WARN} -w
		   ;;
		c) CRIT=$OPTARG
		   check_int ${CRIT} -c
		   check_range ${CRIT} -c
		   ;;
		t) SLEEP=$OPTARG
		   check_int ${SLEEP} -t
		   ;;
		*) exit 20 ;;
	esac
done


# Check for notify-send
which notify-send > /dev/null 2>&1 || exit 10

while true; do

CAPSUM="0"
BATCOUNT="0"

# Don’t test when on AC
[[ $(cat ${CHK}/AC/online) -eq 1 ]] && break



for BAT in ${CHK}/BAT*; do
	CAPACITY="$(cat ${BAT}/capacity)"
	(( BATCOUNT++ ))

	RESULT="${RESULT} ${BAT##*/}: ${CAPACITY}%  "
	CAPSUM="$(( ${CAPSUM} + ${CAPACITY} ))"
done

AVERAGE="$(( ${CAPSUM} / ${BATCOUNT} ))"
[[ ${AVERAGE} -lt ${WARN} ]] && WARNING="1" && LEVEL="normal" && MSG="Warning"
[[ ${AVERAGE} -lt ${CRIT} ]] && CRITICAL="1" && LEVEL="critical" && MSG="Critical"

#[[ ${WARNING} -eq 1 ]] && LEVEL="normal" && MSG="Warning"
#[[ ${CRITICAL} -eq 1 ]] && LEVEL="critical" && MSG="Critical"

shopt -s extglob
RESULT="${RESULT%%*( )}"
shopt -u extglob

if [ ${WARNING} -eq 1 -o ${CRITICAL} -eq 1 ]; then
	notify-send --urgency=${LEVEL} "Battery is running low" "LEVEL=${MSG}<br/>CAPACITY=${RESULT}"
	#TODO: Make this message a bit nicer; and include the $AVERAGE value.
	RETVAL="$?"
	# Resetting triggers for next run. Otherwise they will always trigger. sad.
	WARNING="0"
	CRITICAL="0"
fi

RESULT=""

# Leave the loop if called as a system job. e.g. systemd/timer
[[ ${SYSTEM} -eq 1 ]] && break

sleep ${SLEEP}
done

exit ${RETVAL}
