#!/system/bin/sh
e1=$(cat /sys/class/input/event1/device/device/hall_status 2>/dev/null)
if [ "$e1" = "1" ]; then setprop sys.slider.state closed; else setprop sys.slider.state open; fi
