#!/bin/bash
k_lvl="/sys/devices/platform/samsung/leds/samsung::kbd_backlight/brightness"
value="$(cat $k_lvl)"
let value--
if [ "$value" -ge 0 ]; then
    echo $value > $k_lvl
fi
