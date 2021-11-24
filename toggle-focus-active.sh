#!/bin/bash
if [ -n "$ZSH_VERSION" ]; then emulate -L ksh; fi # Zsh compatibility
## @todo Cleanup for POSIX

usage() {
	echo "Usage: ${*/0} -a APPLICATIONA1,APPLICATIONA2,... -b APPLICATIONB1,APPLICATIONB2,... [ -t | -s SLEEP | -v]"
}

if [ $# -lt 3 ]; then
	usage
	exit 1
else
	IFS=','
	while getopts "a:b:s:tqv" ARG; do
		case ${ARG} in
			a)
				APPLICATIONSA=(${OPTARG})
			;;
			b)
				APPLICATIONSB=(${OPTARG})
			;;
			s)
				SLEEP=${OPTARG}
			;;
			t)
				TOGGLE=1
			;;
			q)
				QUIET=1
			;;
			v)
				VERBOSE=$((++VERBOSE))
				VERBOSE_INIT=1
			;;
			*)
				usage
				exit 1
			;;
		esac
	done
	# Defaults
	SLEEP=${SLEEP-1}
	TOGGLE=${TOGGLE-0}
	VERBOSE=${VERBOSE-0}
	VERBOSE_INIT=${VERBOSE_INIT-0}
	PIDRE='^[0-9]*$'
	if [ ${QUIET-0} -gt 0 ]; then
		VERBOSE=-1
	fi
fi

IFS=" "
if [ $VERBOSE -gt 0 ]; then
	echo "Set verbosity level to ${VERBOSE}"
fi

trap 'TRAP=0; break 1;' 2
TRAP=1
while [ ${TRAP} -eq 1 ]; do
	if [ $VERBOSE -gt 0 ]; then
		echo "Loop $((++LOOP))"
	fi
	# Get current window PID -- There are exceptions (SHRK)
	PID=$(xdotool getwindowfocus getwindowpid 2>/dev/null)
	if [ "${PID:+x}" = "x" ]; then
		WINID="$(xdotool getwindowfocus getactivewindow)"
		PID="$(xprop -id ${WINID} | awk '/_NET_WM_PID\(CARDINAL\)/{print $NF}')"
		# EXE="$(readlink "/proc/${PID}/exe" | sed 's#.*/##')"
		if [ -s "/proc/${PID}/exe" ]; then
			EXE="$(readlink "/proc/${PID}/exe")"
			CMDNAME="${EXE##*/}"
		fi
	elif [[ ${PID} =~ ${PIDRE} ]]; then
		CMDNAME=$(ps -fp ${PID} -o command -h 2>/dev/null | awk '{x=$1; sub(".*/", "", x); print x}')
	else
		if [ $VERBOSE -gt 0 ]; then
			echo "Skipping on ${PID}"
		fi
		sleep ${SLEEP}
		continue
	fi
	# Set application state
	if command -v "$CMDNAME" &>/dev/null || ps ${PID} &>/dev/null; then
		if [ $VERBOSE -gt 0 ]; then
			echo "Detected ${CMDNAME}${CMDNAME+ }${PID}"
		fi
		for APPLICATIONA in "${APPLICATIONSA[@]}"; do
			## @todo Use applications a minus active as applications b
			if [ $VERBOSE -gt 1 ]; then
				echo "Iterating A: ${APPLICATIONA}"
			fi
			PIDA=($(pidof "$APPLICATIONA"))
			if [ ${PIDA:-0} -eq 0 ]; then
				if [ $VERBOSE -gt 0 ]; then
					echo "Skipping A: ${APPLICATIONA}"
				fi
				continue
			fi
			STATEA=$(ps -o state= --pid ${PIDA[0]})
			for APPLICATIONB in "${APPLICATIONSB[@]}"; do
				if [ $VERBOSE -gt 1 ]; then
					echo "Iterating B: ${APPLICATIONB}"
				fi
				PIDB=($(pidof "$APPLICATIONB"))
				if [ ${PIDB:-0} -eq 0 ]; then
					if [ $VERBOSE -gt 0 ]; then
						echo "Skipping B: ${APPLICATIONB}"
					fi
					continue
				fi
				STATEB=$(ps -o state= --pid ${PIDB[0]})
				if [ ${#PIDA[*]} -eq 0 ] || [ ${#PIDB[*]} -eq 0 ]; then
					sleep $((SLEEP*2))
				else
					if [ $VERBOSE_INIT -gt 0 ] && [ $VERBOSE -gt -1 ]; then
						echo "${PIDA%% *} (${STATEA:0:1}) : ${PIDB%% *} (${STATEB:0:1})"
					fi

					if [ "$CMDNAME" = "$APPLICATIONA" ]; then
						if [ "${STATEA:0:1}" = "T" ]; then
						if [ $VERBOSE -gt -1 ]; then
							echo "Releasing ${APPLICATIONA}"
						fi
							kill -s CONT ${PIDA[*]}
						fi
						if [ $TOGGLE -gt 0 ] && [ "${STATEB:0:1}" = "S" ]; then
							if [ $VERBOSE -gt -1 ]; then
								echo "Freezing ${APPLICATIONB}"
							fi
							kill -s STOP ${PIDB[*]}
						fi

					elif [ "$CMDNAME" = "$APPLICATIONB" ]; then
						if [ "${STATEA:0:1}" = "S" ]; then
							if [ $VERBOSE -gt -1 ]; then
								echo "Freezing ${APPLICATIONA}"
							fi
							kill -s STOP ${PIDA[*]}
						fi
						if [ $TOGGLE -gt 0 ] && [ "${STATEB:0:1}" = "T" ]; then
							if [ $VERBOSE -gt -1 ]; then
								echo "Releasing ${APPLICATIONB}"
							fi
							kill -s CONT ${PIDB[*]}
						fi
					fi
					sleep ${SLEEP};
				fi
			done
		done
	else
		sleep $((SLEEP*2));
	fi
done
