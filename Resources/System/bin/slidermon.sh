#!/system/bin/sh
# Slider screen control – EVENT‑DRIVEN version
# Uses the raw input event from hall sensors (event1 = hall0)
# No polling, no sleep → instant reaction, works even after suspend.

# ---- CONFIGURATION ----
# Hall0 (open/close) → /dev/input/event1
# Backlight sysfs   → /sys/class/leds/lcd-backlight/brightness
# Power‑key event   → /dev/input/event3   (qpnp_pon)

CLOSE_EV=/dev/input/event1   # hall0
BL=/sys/class/leds/lcd-backlight/brightness
EV=/dev/input/event3

# ---- FUNCTION TO INJECT POWER KEY EVENT ----
pwr() {
    # $1 = 0 for POWER OFF, 1 for POWER ON
    sendevent $EV 1 116 $1
    sendevent $EV 0 0 0
}

# ---- HOLD WAKELOCK TO PREVENT DEEP SUSPEND ----
echo slidermon > /sys/power/wake_lock 2>/dev/null

# ---- MAIN LOOP: BLOCK ON HALL0 INPUT EVENT ----
while true; do
    # Block until a new input event appears on hall0 (event1)
    cat $CLOSE_EV > /dev/null   # this call blocks until kernel writes an event

    # Read current state of hall0 (0 = open, 1 = closed)
    h0=$(cat /sys/devices/soc.0/hall_sensor0.72/hall_status 2>/dev/null)
    # Read current backlight brightness
    bl=$(cat $BL 2>/dev/null)

    if [ "$h0" = "1" ]; then          # slider fully closed
        [ "$bl" != "0" ] && pwr 0      # if screen on → turn it off
    else                               # slider open (partial or full)
        [ "$bl" = "0" ] && pwr 1      # if screen off → turn it on
    fi
done