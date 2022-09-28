#!/sbin/sh

. $tmp/LNG/english.sh

if (mygrep_arg "Force reading arguments.txt" | grep -q "true"); then
    MYLNG=$(mygrep_arg "Language")
    [[ -f $tmp/LNG/${MYLNG}.sh ]] && . $tmp/LNG/${MYLNG}.sh || $tmp/LNG/english.sh
elif [[ -z $LNGarg ]]; then
    LNG_tmp=$tmp/LNG/
    A=1
    for files in ${LNG_tmp}*; do
        [[ -z $LNGL ]] &&
            LNGL="$(basename ${files%.sh*})$LNGL" ||
            LNGL="$(basename ${files%.sh*})\n$LNGL"
        LNGL2="$(basename ${files%.sh*}) $LNGL2"
        ticks_lang=$((ticks_lang + 1))
    done
    for files in $LNGL2; do
        . ${LNG_tmp}$files.sh
        my_print "> [$files]" "selected"
        my_print "{Choose English language: Thank you all for the translation}"
        my_print "Volume up (+) for switching" "selected"
        my_print "Volume down (-) for select" "selected"
        ui_print " "
    done
    while true; do
        LNGsell=$(echo -e "$LNGL" | head -n$A | tail -n1)
        my_print " > $LNGsell <" "selected"
        if chooseport 60; then
            A=$((A + 1))
        else
            break
        fi
        if [ $A -gt $ticks_lang ]; then
            A=1
        fi
    done
    my_print " >[$LNGsell]<" "selected"
    . ${LNG_tmp}$LNGsell.sh
    ui_print " "
elif ! [[ -z $LNGarg ]]; then
    . $LNGarg
fi
if ! (mygrep_arg "Force reading arguments.txt" | grep -q "true"); then

    if $my_magisk_installer && [ -d /data/data/com.termux/ ] && ! [ "$4" == "termux" ]; then
        {
            MYSELECT \
                "Open Termux for further installation?" \
                "OPEN TERMUX:select:YES:comment:More UI stability in TERMUX" \
                "CONTINUE IN MAGISK-APP:select:NO:comment:Less UI stability in MAGISK"
        } && {
            rm -f /data/data/com.termux/customize.sh /data/data/com.termux/install.zip
            unzip -o "$arg3" \
                "customize.sh" \
                -j -d /data/data/com.termux/ &>$(dirname $arg3)/log.txt
            cp "$arg3" /data/data/com.termux/install.zip
            chmod 777 /data/data/com.termux/customize.sh
            chmod 777 /data/data/com.termux/install.zip
            am force-stop com.termux
            am start com.termux/com.termux.HomeActivity
            sleep 0.4
            input text 'su -c sh /data/data/com.termux/customize.sh 1 2 "/data/data/com.termux/install.zip" "termux" "'${LNG_tmp}$LNGsell.sh'"'
            input keyevent KEYCODE_ENTER
            exit 0
        }
    fi
fi

my_print "Welcome to DFE-NEO $DFENV"
my_print "by TG/XDA - LeeGarChat"
my_print "TG group @PocoF3DFE"
my_print "Thanks for the Magisk team"
#DEL="$MYSKIPP>> $( dirname $arg3 )/log.txt"

# Device A/B check

#sleep 1

my_print "Devices: $(getprop ro.build.product)"
my_print "Model: $(getprop ro.product.model)"
my_print "CPU architecture: $CPU"
my_print "Detected active slot: $slot_ab"

read_argumetns_file
if (mygrep_arg "Force reading arguments.txt" | grep -q "true"); then
    first_select=2
else
    ui_print " "
    my_print "Parameters that are written in arguments.txt :"
    reset_arguments
    read_argumetns_file
    show_arguments
    ui_print " "
    my_print "Volume up (+) for switching"
    my_print "Volume down (-) for select"
    {
        MYSELECT \
            "Do you want to use arguments.txt?" \
            "Configure Arguments now" \
            "Use arguments.txt"
    } && first_select=1 || first_select=2
fi
case $first_select in
2) sleep 0.1 ;;
1)
    reset_arguments

    {
        MYSELECT \
            "Install DFE-NEO or DFE-Legacy?" \
            "Install NEO method:select:DFE-NEO:comment:The boot partition will be patched. RW rights are not necessary" \
            "Install Legacy method:select:DFE-LEGACY:comment:The vendor section will be patched or another section in which fstabs will be located. Need RW rights"
    } && legacy_mode=false || legacy_mode=true
    {
        MYSELECT \
            "Do you want to adjust the patching parameters of DFE QUOTA AVB?" \
            "DEFAULT" \
            "YES"
    } && {
        AVB_STAY=true
        QUOTA_STAY=true
    } || {
        {
            MYSELECT \
                "Disable QUOTA?" \
                "NO" \
                "YES"
        } && QUOTA_STAY=false || QUOTA_STAY=true
        {
            MYSELECT \
                "Disable AVB?" \
                "NO" \
                "YES"
        } && AVB_STAY=false || AVB_STAY=true
    }
    $my_magisk_installer && {
        {
            MYSELECT \
                "Reflash recovery after OTA?" \
                "YES" \
                "NO"
        } && Reflash_Recovery_After_Oat=true || Reflash_Recovery_After_Oat=false
    } || {
        {
            MYSELECT \
                "Do you want to reinstall the current Recovery? The function works correctly only for devices, where RECOVERY is in BOOT" \
                "YES" \
                "NO"
        } && Flash_Current_Rerovery=true || Flash_Current_Rerovery=false
    }
    {
        MYSELECT \
            "Do you want to install the built-in DFE-NEO Magisk v${MAGISK_VER}?" \
            "YES" \
            "NO"
    } && Flash_Magisk=true || Flash_Magisk=false
    {
        MYSELECT \
            "Do you want to hide the disabled encryption of the device? For example, the device settings will show that your device is encrypted, but in fact it is decrypted" \
            "NOT HIDDEN:comment:The system will detect that your phone has been decrypted" \
            "HIDDEN:comment:The system will display that your phone is encrypted. for more stability"
    } && Hide_No_Encryption=false || Hide_No_Encryption=true
    {
        MYSELECT \
            "Do you want to configure additional features?" \
            "YES" \
            "NO"
    } && {
        $Flash_Magisk && {
            MYSELECT \
                "Enable in-built DFE-NEO Safetynet fix?" \
                "ENABLE:select:YES" \
                "DISABLE:select:NO"
        } && safetyfix=true || safetyfix=false
        $Flash_Magisk && {
            MYSELECT \
                "Force to enable zygisk mode for magisk at system startup? After installing DFE-NEO, zygisk mode for magisk will be permanently enabled, to turn it off, you will need to flash DFE-NEO without this mode" \
                "FORCE ENABLE ZYGISK:select:YES" \
                "DISABLE FORCE ZYGISK:select:NO"
        } && force_zygisk=true || force_zygisk=false
        $Flash_Magisk && {
            MYSELECT \
                "Add custom packages/applications automatically to denylist after system boot? The zygisk mode must be enabled. Packages in denylist.txt : $(wc -l $tmp/denylist.txt | awk '{print $1}')" \
                "ENABLE CUSTOM DENYLIST:select:YES" \
                "NOT YET:select:NO"
        } && add_deny_list=true || add_deny_list=false
        {
            MYSELECT \
                "Skip the mini tutorial on proper use after installation?" \
                "DONT SKIP:select:NO" \
                "SKIP:select:YES"
        } && skip_warning=false || skip_warning=true
        {
            MYSELECT \
                "Do wipe data after successful installation?" \
                "DONT WIPE:select:NO:comment:If your device has already been decrypted and you are updating the ROM" \
                "WIPE DATA:select:YES:comment:if your device is already decrypted and you change the ROM"
        } && wipe_data=false || wipe_data=true
        (! $wipe_data && [ -f /data/system/locksettings.db ] && ! $my_magisk_installer) && {
            MYSELECT \
                "Do you want to remove the lockscreen pin?" \
                "DONT TOUCH LOCKCREEN:select:NO" \
                "REMOVE LOCKCREEN PIN:select:YES"
        } && rem_lock=false || rem_lock=true
        {
            MYSELECT \
                "Do you want to disable the dynamic refresh rate of the display? Only for MIUI" \
                "DISABLE DYNAMIC REFRESH RATE:select:YES" \
                "RETAIN DYNAMIC REFRESH RATE:select:NO"
        } && dynamic120hz=true || dynamic120hz=false
        MYSELECT \
            "Restart the device after a successful installation?" \
            "DONT RESTART:select:NO" \
            "RESTART TO SYSTEM:select:SYSTEM" \
            "RESTART TO RECOVERY:select:RECOVERY" \
            "RESTART TO BOOTLOADER/FASTBOOT:select:BOOTLOADER/FASTBOOT"
        selectreturn=$?
        if [ $selectreturn = 1 ]; then
            rebootafter=false
        elif [ $selectreturn = 2 ]; then
            rebootafter=true
            rebootARG=system
        elif [ $selectreturn = 3 ]; then
            rebootafter=true
            rebootARG=recovery
        elif [ $selectreturn = 4 ]; then
            rebootafter=true
            rebootARG=bootloader
        else
            rebootafter=false
            rebootARG=""
        fi
    }
    ;;
esac

if ! $Flash_Magisk &&
    ! $Flash_DFE &&
    ! $Flash_Current_Rerovery; then
    my_abort 71
fi

timer_start2=$(date +%s%N)

my_print "Starting the installation with these parameters:"

show_arguments

$force_zygisk && ! $legacy_mode || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} zygisk_on||g' "$tmp"/init.rc
}

$add_deny_list && ! $legacy_mode || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} add_denylist||g' "$tmp"/init.rc
}
$Hide_No_Encryption || {
    sed -i 's|setprop ro.crypto.state encrypted||' "$tmp"/init.rc
}
$QUOTA_STAY || {
    sed -i 's|echo "quota"|#echo "quota"|' "$tmp"/init.sh
}
$safetyfix || {
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_fs||g' "$tmp"/init.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_init||g' "$tmp"/init.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_boot_complite||g' "$tmp"/init.rc
}
$AVB_STAY || {
    sed -i 's|echo "avb="|#echo "avb="|' "$tmp"/init.sh &&
        sed -i 's|echo "avb_keys="|#echo "avb_keys="|' "$tmp"/init.sh &&
        sed -i 's|echo "avb"|#echo "avb"|' "$tmp"/init.sh
}
$dynamic120hz && ! $legacy_mode || {
    sed -i 's|#exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic|' "$tmp"/init.rc
}
