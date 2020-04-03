# bat-status
Check battery capacity and send desktop notification via `notify-send`
if it gets low.

The battery capacity is read from `/sys/class/ppower_supply/BAT*/capacity`.
For every battery the current capacity is taken and a warning notification
is displayed if the average capacity sinks below the $WARN or $CRIT treshold.

## Install and run

Either run the script yourself, put it in your autostart or use the systemd
service and timer which are part of this repository.
If you use the timer, install the shell script to `/opt/bat-status/bat-status.sh`
and put the `.service` and `.timer` files in `/etc/systemd/system/`.
Then you need to `systemctl daemon reload` and activate the timer with
`systemctl start bat-status.timer`. Also enable the unit to load on system start
`systemctl enable bat-status-timer`.

### Dependencies

* notify-send
* cat (cats are important to everything!)


## Options and arguments

Calling bat-check.sh by itself has reasonable defaults. Without any options
the script reruns every 30 seconds.

some of these are not yet implemented.

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
