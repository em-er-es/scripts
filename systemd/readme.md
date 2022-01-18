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
