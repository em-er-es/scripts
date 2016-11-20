#!/bin/bash
STEPS=5;
INTERVAL=0.05;
if [[ ! -z "$ALSA_DEFAULT_CARD" ]]; then CARD="$ALSA_DEFAULT_CARD"; else CARD="PCH"; fi
if [[ ! -z "$ALSA_DEFAULT_CTL" ]]; then CONTROL="$ALSA_DEFAULT_CTL"; else CONTROL="Master"; fi

for i in $(seq $STEPS); do
	amixer -q $@;
	sleep $INTERVAL;
done

VOL=$(amixer -c "$CARD" sget "$CONTROL" | awk '/dB/{x = $3 * 2; print x}');
dd if=/dev/zero of=/tmp/vol/volume count="$VOL"
