#!/bin/bash
ALSADEV="PCH";
ALSAHWDEV="hw:$ALSADEV";
HPLEVEL=80;
SPLEVEL=127;
FULLVOL=('Master' 'Speaker' 'PCM');
MUTEVOL=('Headphone');
CHECKCTRL='Auto-Mute Mode';
STATEFILESP="/run/asound-sp.state";
STATEFILEHP="/run/asound-hp.state";

checksw(){
amixer -D "$ALSAHWDEV" get "${CHECKCTRL}" | grep -e "Item0"\.\*"Enabled" &>/dev/null && \
amixer -D "$ALSAHWDEV" get "${MUTEVOL[0]}" | grep -e "Front Left:"\.\*'\[on\]$' -e "Front Right:"\.\*'\[on\]$' &>/dev/null && \
swhp || swsp;
}

swsp(){
alsactl store "$ALSADEV" -f "$STATEFILEHP";
if [[ -f "$STATEFILESP" ]]; then 
	alsactl restore "$ALSADEV" -f "$STATEFILESP";
else 
	for CCTRL in $(seq 1 ${#MUTEVOL[@]}); do
		amixer -D "$ALSAHWDEV" set "${MUTEVOL[$((CCTRL-1))]}" mute &> /dev/null;
	done
	for CCTRL in $(seq 1 ${#FULLVOL[@]}); do
		amixer -D "$ALSAHWDEV" set "${FULLVOL[$((CCTRL-1))]}" $SPLEVEL unmute &> /dev/null;
	done
fi
}

swhp(){
alsactl store "$ALSADEV" -f "$STATEFILESP";
if [[ -f "$STATEFILEHP" ]]; then 
	alsactl restore "$ALSADEV" -f "$STATEFILEHP";
else
	for CCTRL in $(seq 1 ${#MUTEVOL[@]}); do
		amixer -D "$ALSAHWDEV" set "${FULLVOL[0]}" $HPLEVEL unmute &> /dev/null;
		amixer -D "$ALSAHWDEV" set "${MUTEVOL[$((CCTRL-1))]}" 127 unmute &> /dev/null;
	done
	for CCTRL in $(seq 1 ${#FULLVOL[@]}); do
		if [[ "${MUTEVOL[$((CCTRL-1))]}" == "Speaker" ]]; then
			amixer -D "$ALSAHWDEV" set "${FULLVOL[$((CCTRL-1))]}" mute &> /dev/null;
		fi
	done
fi
}

if [[ $# -eq 0 ]]; then checksw; elif [[ "$@" == [hH][pP] ]]; then swhp; else swsp "$@"; fi
