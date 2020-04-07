# bat-status
Check battery capacity and send desktop notification via `notify-send`
if the voltage drops to a certain level.

The battery charge percentage is read from `/sys/class/power_supply/BAT*/capacity`.
For every battery the current charge is taken and a warning notification
is displayed if the average battery level sinks below the $WARN or $CRIT threshold.

## Install and run

Either run the script yourself, put it in your autostart or use the systemd
service and timer which are part of this repository.
If you use the timer, install the shell script to `/opt/bat-status/bat-status.sh`
and put the `.service` and `.timer` files in `/etc/systemd/system/`.
Edit in `bat-status.service` edit the user ID of the user for which the check
should run. Also make sure the `DBUS_SESSION_BUS_ADDRESS` is set to the correct
value. If it doesn’t work, try adding a `DISPLAY` and/or `XAUTHORITY` variable.
To load the new systemd files you have to reload the daemon with
`systemctl daemon-reload`. You can start the service and enable it
on system startup with `systemctl enable --now bat-status.timer`.

### Dependencies

* notify-send
* cat (cats are important to everything!)


## Options and arguments

Calling bat-check.sh by itself has reasonable defaults. Without any options
the script reruns every 30 seconds.

*some of these are not yet implemented.*

```
-h      Display help
-s      Indicates this script is started via systems/timer and will not loop.
-w INT  Set the warning treshold. Defaults to 20
-c INT  Set the critical treshold. Defaults to 15
-t INT  Set the loop timer after which the script runs again. Defaults to 30 seconds.
```


### Examples

`bat-check.sh -w 50 -c 10`  
Set the warning treshold to 50% and critical treshold to 10% battery capacity.

`bat-check.sh -t 120`  
Set the loop timer to 2 minutes. The script will rerun after this time.
