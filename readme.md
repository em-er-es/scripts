# Collection of scripts

A collection of scripts that might be useful for various applications.

## Scripts

List of scripts:

| Script | Description |
|:------:|:-----------:|
| aamixer.sh | Smooth ALSA mixer control |
| toggle-focus-active.sh | Scipt toggles process state via sending STOP/CONT signals between set of application based on what is in focus. This can help free up limited resources and automate switching context between resource heavy applications. |
| wm-sort.py | Sort windows according to regex patterns. Can use external `yaml` files as configuration. |
|  |  |

## Gists

List of gists that didn't make it into this repository:

| Script | Description | URL |
|:------:|:-----------:|:---:|
|  |  |  |

## Systemd

List of systemd entries:

| Entity | Description |
|:------:|:-----------:|
| bluetooth-rt3290.service | Handles the RT3290 bluetooth kernel module |
| stop-during-suspend@.service | Suspends services for the duration of sleep cycle |
| stop-during-suspend@bluetooth-rt3290.service | Suspends BT service to sustain functionality after resume |
