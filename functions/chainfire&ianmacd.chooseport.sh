#!/bin/sh
chooseport() {
    # Original idea by chainfire and ianmacd @xda-developers
    [ "$1" ] && local delay=$1 || local delay=3
    local error=false
    while true; do
        local count=0
        while true; do
            timeout 0.5 /system/bin/getevent -lqc 1 2>&1 >$tmp/events &
            sleep 0.1
            count=$((count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $tmp/events); then
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $tmp/events); then
                return 1
            fi
            [ $count -gt 100 ] && break
        done
        if $error; then
            ui_print "$text119"
            exit 90
        else
            error=true
            ui_print " "
            ui_print "$text120"
        fi
    done
}