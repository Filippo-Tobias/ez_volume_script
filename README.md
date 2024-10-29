This script makes a pipe in /tmp/ez-volume/pipe,
to communicate with the pipe just echo "volume_[volume]" where [volume] is the volume you want to increase by.
this should be a number between 0.01 and 1.00, if you want to decrease just add a "-" sign before the number.
This script only works with hyprland as it uses hyprctl to get the current active window's PID to change
the volume of its streams.
