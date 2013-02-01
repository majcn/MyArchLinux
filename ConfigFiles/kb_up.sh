#!/bin/bash
k_lvl="/sys/devices/platform/samsung/leds/samsung::kbd_backlight/brightness"
value="$(cat $k_lvl)"
let value++
if [ "$value" -le 8 ]; then
    echo $value > $k_lvl
fi
