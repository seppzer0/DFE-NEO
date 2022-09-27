#!/sbin/sh
mygrep_prop() { echo $(grep "$1" "$2" | sed 's|'"$1"'=||') ; }