#!/bin/bash
STEPS=5;
INTERVAL=0.05;

for I in $(seq ${STEPS}); do
	amixer -q ${@};
	sleep ${INTERVAL};
done
