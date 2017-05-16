#!/bin/bash
EQDEV="equalizer";
EQRESETLEVEL=60;
EQBANDS=('00. 31 Hz' '01. 63 Hz' '02. 125 Hz' '03. 250 Hz' '04. 500 Hz' '05. 1 kHz' '06. 2 kHz' '07. 4 kHz' '08. 8 kHz' '09. 16 kHz');
EQBANDSL=('31 Hz' '63 Hz' '125 Hz' '250 Hz' '500 Hz' '1 kHz' '2 kHz' '4 kHz' '8 kHz' '16 kHz');
EQP00=('Full attenuation' 0 0 0 0 0 0 0 0 0 0); # Full attenuation
EQP0F=('Full gain' 100 100 100 100 100 100 100 100 100 100); # Full gain
EQP01=('Passive loudness' 60 56 52 48 44 54 56 58 60 60); # Passive
EQP02=('Active loudness' 68 64 60 55 50 60 62 64 66 68); # Active
SEP1='\t';
SEP2='\n';
BANDS=0;
GRAPH=0;
C0='\u25a1';
C0='-';
CF='\u25a0'; #
CH='\u2591';
CC='258';


geteq(){
for EQB in $(seq 1 ${#EQBANDS[@]}); do
	EQVOL="$(amixer -D "$EQDEV" get "${EQBANDS[$((EQB-1))]}" | awk '/Front\ Left:/{lv=$NF} /Front\ Right:/{rv=$NF} END{print lv rv}')";
	if [ ${GRAPH} -eq 1 ]; then
		# Double assignment for Bash compatibility
		LV=${EQVOL%%\%]*]}; LV=${LV/\[};
		RV=${EQVOL/\[}; RV=${RV/\%*};
		printf '   \t';
		for i in $(seq 0 10 100); do
			if [[ ${LV} -gt ${i} ]]; then printf ${CF}; elif [[ ${LV} -eq ${i} ]];then printf ${C0}; else printf "\u${CC}$((LV+10-i))"; break; fi
		done
		printf "|   \t${EQBANDS[$((EQB-1))]}   \t|";
		for i in $(seq 0 10 100); do
			if [[ ${RV} -gt ${i} ]]; then printf ${CF}; elif [[ ${RV} -eq ${i} ]];then printf ${C0}; else printf "\u${CC}$((RV+10-i))"; break; fi
		done
		echo '|';
	else
		echo -en "${EQBANDS[$((EQB-1))]}${SEP1}$EQVOL${SEP2}";
	fi
done
}

reseteq(){
echo -en "Reset${SEP2}";
for EQB in $(seq 1 ${#EQBANDS[@]}); do
	amixer -D "$EQDEV" set "${EQBANDS[$((EQB-1))]}" "$EQRESETLEVEL" &> /dev/null;
done
}

seteq(){
eval EQPRESET='${'$@'[@]}';
eval 'echo ${'$@'[0]}'
for EQB in $(seq 1 ${#EQBANDS[@]}); do
	eval EQPRESETB='${'$@'['$((EQB))']}';
	amixer -D "$EQDEV" set "${EQBANDS[$((EQB))]}" "${EQPRESETB}" &> /dev/null;
	if [[ $BANDS -eq 1 ]]; then
		echo -en "${EQBANDS[$((EQB))]}${SEP1}${EQPRESETB}${SEP2}";
	fi
done
}

seteqb(){
eval EQPRESET='${'$@'[@]}';
for EQB in $(seq 1 ${#EQBANDS[@]}); do
        eval EQPRESETB='${'$@'['$((EQB-1))']}';
        amixer -D "$EQDEV" set "${EQBANDS[$((EQB-1))]}" "${EQPRESETB}" &> /dev/null;
        echo "${EQBANDS[$((EQB-1))]}" "${EQPRESETB}";
done
}

while [ $# -gt 0 ]; do
	case "$1" in
		b|-b|--bands)
		BANDS=1;
		if [ $# -eq 1 ]; then geteq; fi;;

		g|-g|--graph*)
		GRAPH=1;
		if [ $# -eq 1 ]; then geteq; fi;;

		r|-r|--reset|[rR][eE][sS][eE][tT])
		reseteq;;

		EQP*)
		if [ "$(eval 'echo ${'"$1"'-emptytest}')" = "emptytest" ]; then
			echo "Incorrect preset name. Available presets:";
			for P in ${!EQP*}; do
				eval 'echo "$P: \"${'$P'[0]}\""';
			done;
			exit 1;
		else
			seteq "$1";
		fi
		;;

		*)
		echo "Current equalizer settings:";
		geteq;
		echo "Incorrect preset name. Available presets:";
		for P in ${!EQP*}; do
			eval 'echo "$P: \"${'$P'[0]}\""';
		done;
		exit 1;
		;;
	esac
	shift;
done
