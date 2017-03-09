#!/bin/bash
EQDEV="equalizer";
EQRESETLEVEL=60;
EQBANDS=('00. 31 Hz' '01. 63 Hz' '02. 125 Hz' '03. 250 Hz' '04. 500 Hz' '05. 1 kHz' '06. 2 kHz' '07. 4 kHz' '08. 8 kHz' '09. 16 kHz');
EQP00=(0 0 0 0 0 0 0 0 0 0); # Full turn down
EQP01=(60 56 52 48 44 54 56 58 60 60); # Passive
EQP02=(68 64 60 55 50 60 62 64 66 68); # Active
EQP0F=(100 100 100 100 100 100 100 100 100 100); # Full gain

geteq(){
for EQB in $(seq 1 ${#EQBANDS[@]}); do
	EQVOL="$(amixer -D "$EQDEV" get "${EQBANDS[$((EQB-1))]}" | awk '/Front\ Left:/{lv=$NF} /Front\ Right:/{rv=$NF} END{print lv rv}')";
	echo "${EQBANDS[$((EQB-1))]}" "$EQVOL";
done
}

reseteq(){
for EQB in $(seq 1 ${#EQBANDS[@]}); do
	amixer -D "$EQDEV" set "${EQBANDS[$((EQB-1))]}" "$EQRESETLEVEL" &> /dev/null;
	echo "${EQBANDS[$((EQB-1))]}" "$EQRESETLEVEL";
done
}

seteq(){
eval EQPRESET='${'$@'[@]}';
for EQB in $(seq 1 ${#EQBANDS[@]}); do
	eval EQPRESETB='${'$@'['$((EQB-1))']}';
	amixer -D "$EQDEV" set "${EQBANDS[$((EQB-1))]}" "${EQPRESETB}" &> /dev/null;
	echo "${EQBANDS[$((EQB-1))]}" "${EQPRESETB}";
done
}


if [[ $# -eq 0 ]]; then geteq; else
	case "$@" in
		[rR][eE][sS][eE][tT])
		reseteq;;
		EQP*)
		seteq "$@";;
		*)
		echo "Current equalizer settings:";
		geteq;
		echo -e "Incorrect preset name. Available presets:\n${!EQP*}";
		exit 1;
	esac
fi
