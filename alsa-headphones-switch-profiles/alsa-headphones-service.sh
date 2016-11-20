#!/bin/bash
STATEFILESP="/run/asound-sp.state";
STATEFILEHP="/run/asound-hp.state";

if [[ ! -f "$STATEFILEHP" ]]; then cp -v "/etc/asound-hp.state" "$STATEFILEHP"; fi
if [[ ! -f "$STATEFILESP" ]]; then cp -v "/etc/asound-sp.state" "$STATEFILESP"; fi

while :; do
	bash /etc/systemd/scripts/alsa-headphones.sh;
done
