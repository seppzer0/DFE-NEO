#!/sbin/sh
if $rem_lock && ! $my_magisk_installer; then
    my_print "$text86"
    rm -f /data/system/locksettings*
fi
#rm -rf $tmp
#[[ -d $tmp_super_part ]] && rm -rf $tmp_super_part

timer_end=$(date +%s%N)
timer_time1=$(expr $timer_end - $timer_start1)
timer_time2=$(expr $timer_end - $timer_start2)
second_time1=$(expr $timer_time1 / 1000000000)
second_time2=$(expr $timer_time2 / 1000000000)
msecond_time1=$(expr ${timer_time1#*$second_time1} / 10000000)
msecond_time2=$(expr ${timer_time2#*$second_time2} / 10000000)
if $wipe_data; then
    my_print "Wiping data"
    find /data -maxdepth 1 -mindepth 1 -not -name "media" -exec rm -rf {} \;
fi

mkdir -p $MAGISKBIN &>$(dirname $arg3)/log.txt
cp -af $BINDIR/. $tmp/magisk_files_tmp/* $BBBIN $MAGISKBIN
chmod -R 755 $MAGISKBIN

my_print " "
my_print " "
my_print "$text87 ${second_time1}.$msecond_time1 $text88"
my_print "$text89 ${second_time2}.$msecond_time2 $text88"
ui_print "    $text90"
ui_print "    **** v$DFENV ****"
my_print " "
my_print " "
$BOOTMODE || recovery_cleanup
rm -rf $TMPDIR $tmp
[[ -f /data/adb/modules_update/DFENEO/customize.sh ]] && rm -rf /data/adb/modules_update/DFENEO
[[ -f /data/adb/modules/DFENEO/customize.sh ]] && rm -rf /data/adb/modules/DFENEO
if $Flash_DFE && ! $skip_warning; then
    sleep 2
    my_print " "
    my_print "$text91"
    my_print "$text91"
    my_print "$text91"
    my_print "$text91"
    my_print " "
    sleep 1
    if $my_magisk_installer; then
        if ! $ISENCRYPTED || [[ $(getprop ro.dfe.neo.state) == "decrypted" ]]; then
            ui_print "************************************"
            ui_print " "
            my_print "$text92"
            ui_print " "
            ui_print "************************************"
        else
            ui_print "************************************"
            my_print " "
            my_print "$text93"
            my_print " "
            ui_print "************************************"

        fi
    else
        ui_print "************************************"
        ui_print " "
        my_print "$text94"
        ui_print " "
        ui_print "************************************"
    fi
    if ! $legacy_mode; then
        my_print "$text95"
        ui_print " "
        sleep 1
        my_print "$text96"
        ui_print " "
        sleep 1
        my_print "$text97"
        ui_print " "
        sleep 1
        my_print "$text98"
        ui_print " "
        sleep 1
        my_print "$text99"
        ui_print " "
    else
        my_print "$text100"
        ui_print " "
    fi
    if $my_magisk_installer; then
        ui_print " "
        ui_print " "
        ui_print " "
        ui_print " "
    fi
fi
if $rebootafter; then
    ui_print "$text101 $rebootARG $text102..."
    n=7
    while ! [ $n = "-1" ]; do
        sleep 1
        ui_print "-  ${n}s..."
        n=$((n - 1))
    done
    reboot $rebootARG
fi

exit 0