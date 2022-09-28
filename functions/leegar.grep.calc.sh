#!/sbin/sh
mygrep_prop() { grep "$1" "$2" | sed 's|'"$1"'=||'; }
mygrep_arg() { grep "$1" "$tmp/arguments.txt" | sed 's|'"$1"'=||' ; }
calc() { awk 'BEGIN{ print int('"$1"') }'; }
calcF() { awk 'BEGIN{ print '"$1"' }'; }