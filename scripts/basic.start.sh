#!/sbin/sh
arg1="$1" arg2="$2" arg3="$3"
sysboot=$(getprop sys.boot_completed)
if [ $sysboot = 1 ]; then
    umask 022
    ui_print() { echo "$1"; }
    require_new_magisk() {
        ui_print "*******************************"
        ui_print " Please install Magisk v20.0+! "
        ui_print "*******************************"
        exit 1
    }
    OUTFD=$2
    ZIPFILE=$3
    mount /data 2>/dev/null
    [ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
    . /data/adb/magisk/util_functions.sh
    [ $MAGISK_VER_CODE -lt 20000 ] && require_new_magisk
    if [ $MAGISK_VER_CODE -ge 20400 ]; then
        install_module || exit $?
        exit 0
    fi
else
    ui_print() { echo -e "ui_print $1\nui_print" >>"/proc/self/fd/$arg2"; }
    tmp=/dev/dfedfe
    mkdir -pv $tmp
    cp "$arg3" "$tmp/dfeneo.zip"
    arg3="$tmp/dfeneo.zip"
    unzip -o "$arg3" \
        "customize.sh" \
        -j -d $tmp/ >>/dev/null
    sh $tmp/customize.sh "$arg1" "$arg2" "$arg3"
    exit $?
fi
exit 0
