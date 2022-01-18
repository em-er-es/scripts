# Systemd

## Services

### General

The stop during suspend service can be used to prevent problematic services from being active during sleep state.

Create a symlink to an existing service and enable it via `systemctl`.

```
# cp -v stop-during-suspend@.service /etc/systemd/system/
# cd /etc/systemd/system/
# ln -sv stop-during-suspend@.service stop-during-suspend@bluetooth-rt3290.service
# systemctl daemon-reload
# systemctl enable stop-during-suspend@bluetooth-rt3290.service
```

Alternatively a custom copy of the service can be made and in even more complex scenarios a custom script can be run.

### Bluetooth

The Ralink RT3290/RT3290STA has always had a complicated usage under GNU/Linux. The latest recommended module (driver) for the device as of 2022 is the [`rtbth-dkms`](https://github.com/loimu/rtbth-dkms) with an [Ubuntu and derivatives repository](https://launchpad.net/~blaze/+archive/ubuntu/rtbth-dkms).

Manual steps required to turn BT on along WLAN without issues:

1. Turn BT off: `$ bluetooth off`
2. Turn WLAN off: `$ wifi off`
3. Load the `rtbth` module: `# modprobe rtbth`
4. Turn BT on: `$ bluetooth on`
5. Turn WLAN on: `$ wifi on`

Note: Should the above not work and the kernel ring buffer annotates a failed operation state, it's most likely the hardware is stuck in a firmware loop and a cold re/boot is required.

The bluetooth services `bluetooth-rt3290.service` and `stop-during-suspend@bluetooth-rt3290.service` are intended to be used with `rtbth-dkms` and enable BT.

The `stop-during-suspend@.service` is necessary to keep the BT functional after suspending the system. It might appear it still works after resume, however typically a reset is necessary and sometimes the firmware might get stuck and only a cold boot can help recover functionality. The base service file `stop-during-suspend@.service` needs to be symlinked to the file `stop-during-suspend@bluetooth-rt3290.service`. The exact name is necessary, read `$ man systemd.unit` for more details.

To enable BT on boot run:
```
# systemctl enable bluetooth-rt3290.service
```

To turn BT on run:
```
# systemctl start bluetooth-rt3290.service
```

To turn BT off run:
```
# systemctl stop bluetooth-rt3290.service
```

To reset BT run:
```
# systemctl restart bluetooth-rt3290.service
```
