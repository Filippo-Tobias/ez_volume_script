#!/bin/bash
DIRECTORY="/tmp/ez-volume/pids"
PIPE_PATH="/tmp/ez-volume/pipe"

if [ "$(id -u)" = 0 ]; then
        echo 'do not run as root'
        exit 1
fi

function cleanup {
    $(rm -rf $DIRECTORY/*)
}

trap cleanup EXIT

if [[ ! -p $PIPE_PATH ]]; then
    mkfifo "$PIPE_PATH"
fi

get_stored_volume() { # $1 is the program pid
    FILENAME=$1
    FILEPATH="$DIRECTORY/$FILENAME"
    if [ ! -f "$FILEPATH" ]; then
        touch "$FILEPATH"
        $(echo 1.0 > $FILEPATH)
        echo '1.0' #this is the return value
    else
      echo $(cat $FILEPATH) #this is the return value
    fi 
}

set_stored_volume() { # $1 is the process PID, $2 is the volume argument
    FILENAME=$1
    FILEPATH="$DIRECTORY/$FILENAME"

    if [ ! -f "$FILEPATH" ]; then
        touch "$FILEPATH"
        $(echo $2 > $FILEPATH)
    else
      $(echo $2 > $FILEPATH)
    fi 
}

change_active_window_stream_volumes() { # $1 is the first function parameter, which is the value to add to the volume
    hyprctlOutput=$(hyprctl clients -j | jq -r '.[] | select(.focusHistoryID == 0) | .pid')
    sink_numbers=($(pactl list sink-inputs | awk -v app="$hyprctlOutput" '/Sink Input #/ {id=substr($3, 2)} $0 ~ "application\\.process\\.id = \"" app "\"" && id {print id; id=""}'))
    volume=$(get_stored_volume "$hyprctlOutput")
    volume=$(echo "$volume" "$1"| awk '{printf "%.2f\n", $1 + $2}') # volume is passed into awk, and $S1, the change % is passed into awk too
    set_stored_volume "$hyprctlOutput" "$volume"
}

set_window_stream_volume() {
    if [ "$(ls -1 $DIRECTORY | wc -l)" = 0 ]; then
        return 0
    fi
    for file in $(ls $DIRECTORY/*); do
        pid=$(basename "$file")
        sink_numbers=($(pactl list sink-inputs | awk -v app="$pid" '/Sink Input #/ {id=substr($3, 2)} $0 ~ "application\\.process\\.id = \"" app "\"" && id {print id; id=""}'))
        volume=$(get_stored_volume "$pid")
        set_stored_volume "$pid" "$volume"
        for id in "${sink_numbers[@]}"; do
            $(pactl set-sink-input-volume $id $volume)
        done
    done
}

if [ ! -d "$DIRECTORY" ]; then
    mkdir -p "$DIRECTORY"
fi

while :; do
    set_window_stream_volume
    if read line < "$PIPE_PATH"; then
        if [[ "$line" == volume_* ]]; then
          change_active_window_stream_volumes "${line#volume_}"
        fi
    fi
done
