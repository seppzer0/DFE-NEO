#!/sbin/sh
mygrep_prop() { echo $(grep "$1" "$2" | sed 's|'"$1"'=||'); }
calc() { awk 'BEGIN{ print int('"$1"') }'; }
calcF() { awk 'BEGIN{ print '"$1"' }'; }