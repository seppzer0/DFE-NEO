#!/sbin/sh


timer_start1=$(date +%s%N)
LNGarg="$5"
#exit 1
DFENV="1.5.3.014 BETA"
#SKIPUHNZIP=1

#(mountpoint -q /data/) && tmp="/data/local/tmp-dfe-neo" ||
tmp="/dev/dfe-neo"
sysboot=$(getprop sys.boot_completed)
CPU=$(getprop ro.product.cpu.abi)
rem_lock=false
# TWRP or Magisk check

[ -f /data/adb/modules_update/DFENEO/customize.sh ] && rm -rf /data/adb/modules_update/DFENEO
[ -f /data/adb/modules/DFENEO/customize.sh ] && rm -rf /data/adb/modules/DFENEO
if [ "$sysboot" = 1 ]; then
    if [ $4 = termux ]; then
        arg3="$3"
        clear
    else
        arg3="$(find "$(dirname "$0")"/ -name "*.zip")"
    fi
    arg1=1
    arg2=2
    my_magisk_installer=true
    type flash_image &>$(dirname $arg3)/log.txt || flash_image() { dd if="$1" of="$2"; }
    . /data/adb/magisk/util_functions.sh

else
    arg1="$1"
    arg2="$2"
    arg3="$3"
    my_magisk_installer=false
    type flash_image || flash_image() { dd if="$1" of="$2"; }
    ui_print() { echo -e "ui_print "$1"\nui_print" >>"/proc/self/fd/$arg2"; }
fi

wipe_data=false
rebootafter=false
A_only=false

# Create tmp folder

rm -rf $tmp
mkdir -pv $tmp &>$(dirname $arg3)/log.txt

# CPU and slot check

[ -z "$CPU" ] && my_abort 77
case $CPU in
arm*) cpukey=arm ;;
x86*) cpukey=x86 ;;
esac
#sleep 1