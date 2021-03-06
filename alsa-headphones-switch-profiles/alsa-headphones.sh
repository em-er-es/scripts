#!/bin/bash
if [[ ! -z "$ALSA_DEFAULT_CARD" ]]; then CARD="$ALSA_DEFAULT_CARD"; else CARD="PCH"; fi

STATEFILE="/run/snd-hp.state"
SCRIPT="/etc/systemd/scripts/alsa-switch.sh"
PIN="$(awk '/Pin-ctls.*OUT HP/{IFS=":"; sub(":", "", $2); id=$2; print id}' /proc/asound/"$CARD"/codec\#0)"
POWERSTATE="$(awk '/'$PIN'/{for (i = 0; i < 3; i++){getline}; IFS="="; powerstate=$3; sub("actual=", "", powerstate); print powerstate}' /proc/asound/PCH/codec\#0)"

if [[ "$(cat "$STATEFILE")" != "$POWERSTATE" ]]; then
	case $POWERSTATE in
		D3) #Passive
			bash "$SCRIPT" sp;
			echo "D3" > "$STATEFILE";
			;;
		D0) #Active
			bash "$SCRIPT" hp;
			echo "D0" > "$STATEFILE";
			;;
		*)
			echo $POWERSTATE @ $PIN > "$STATEFILE"
			echo $POWERSTATE @ $PIN;
			;;
	esac

else
	exit;
fi
