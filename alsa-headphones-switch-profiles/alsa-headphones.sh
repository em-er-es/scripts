#!/bin/bash
if [[ ! -z "$ALSA_DEFAULT_CARD" ]]; then CARD="$ALSA_DEFAULT_CARD"; else CARD="PCH"; fi

STATEFILE="/tmp/snd-hp.state"
PIN="$(awk '/Pin-ctls.*OUT HP/{IFS=":"; sub(":", "", $2); id=$2; print id}' /proc/asound/"$CARD"/codec\#0)"
POWERSTATE="$(awk '/'$PIN'/{for (i = 0; i < 3; i++){getline}; IFS="="; powerstate=$3; sub("actual=", "", powerstate); print powerstate}' /proc/asound/PCH/codec\#0)"

if [[ "$(cat "$STATEFILE")" != "$POWERSTATE" ]]; then
	case $POWERSTATE in
		D3) #Passive
			bash /etc/systemd/scripts/alsa-switch.sh sp;
			echo "D3" > "$STATEFILE";
			;;
		D0) #Active
			bash /etc/systemd/scripts/alsa-switch.sh hp;
			echo "D0" > "$STATEFILE";
			;;
		*)
			echo $POWERSTATE @ $PIN;
			;;
	esac

else
	exit;
fi
