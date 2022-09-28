#!/sbin/sh
. $tmp/LNG/english.sh

if (echo $(mygrep_arg "Force reading arguments.txt") | grep -q "true"); then
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
if ! (echo $(mygrep_arg "Force reading arguments.txt") | grep -q "true"); then
    if $my_magisk_installer && [[ -d /data/data/com.termux/ ]] && ! [[ $4 == termux ]]; then
        my_print "Open Termux for further installation?"
        MYSELECT "OPEN TERMUX" "CONTINUE IN MAGISK-APP" "More UI stability in TERMUX" "Less UI stability in MAGISK"
        if [ $? = 1 ]; then
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
        fi
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



(MYSELECT \
    "Hello, its my new function for select. you like it?" \
    "Yeah, its very good:select:YES:comment:I think so" \
    "Nope") && echo true || echo false




read_argumetns_file
if (echo $(mygrep_arg "Force reading arguments.txt") | grep -q "true"); then
    first_select=2
else
    ui_print " "
    my_print "Do you want to use arguments.txt?"
    my_print "Parameters that are written in arguments.txt :"

    ui_print " "
    my_print "Volume up (+) for switching"
    my_print "Volume down (-) for select"

    MYSELECT "Configure Arguments now" "Use arguments.txt"
    #"DFE-method=$legacy_mode, Flash-Magisk=$Flash_Magisk, Hide-No-Encryption=$Hide_No_Encryption, Reflash-Recovery-for-OTA=$Reflash_Recovery_After_Oat, Reflash-current-Recovery=$Flash_Current_Rerovery, DISABLE-DYNAMIC-REFRESHRATE=$dynamic120hz, Wipe-DATA=$wipe_data, Remove-PIN=$rem_lock, Disable-QUOTA=$QUOTA_STAY, Disable-AVB=$AVB_STAY, Reboot-after-installing=${rebootafter}-$rebootARG, Safetynet-fix=$safetyfix, Force-Zygisk-mode=$force_zygisk, Add-castom-packages-automatic-in-denylist=$add_deny_list"
    first_select=$?
fi
case $first_select in
2)
    sleep 0.1

    ;;
1)

    #twrp install "/sdcard/Download/miuipro_v12.0_alioth_22.7.14.zip"
    my_print "Install DFE-NEO or DFE-Legacy?"
    Flash_DFE=true
    MYSELECT "DFE-NEO" "DFE-LEGACY" "The boot partition will be patched. RW rights are not necessary" "The vendor section will be patched or another section in which fstabs will be located. Need RW rights"
    if [ $? = 2 ]; then
        legacy_mode=true
    else
        legacy_mode=false
    fi

    my_print "Do you want to adjust the patching parameters of DFE QUOTA AVB?"
    MYSELECT "DEFAULT" "YES"
    if [ $? = 2 ]; then

        my_print "Disable quota?"
        MYSELECT "DISABLE QUOTA" "ENABLE QUOTA"
        if [ $? = 1 ]; then
            QUOTA_STAY=true
        else
            QUOTA_STAY=false
        fi

        my_print "Disable avb?"
        MYSELECT "DISABLE AVB" "ENABLE AVB"
        if [ $? = 1 ]; then
            AVB_STAY=true
        else
            AVB_STAY=false
        fi

    else
        AVB_STAY=true
        QUOTA_STAY=true
    fi

    if $my_magisk_installer; then
        my_print "Reflash recovery after OTA?"
        MYSELECT "YES" "NO"
        if [ $? = 1 ]; then
            Reflash_Recovery_After_Oat=true
        else
            Reflash_Recovery_After_Oat=false
        fi
    else
        my_print "Do you want to reinstall the current Recovery? The function works correctly only for devices, where RECOVERY is in BOOT"
        MYSELECT "YES" "NO"
        if [ $? = 1 ]; then
            Flash_Current_Rerovery=true
        else
            Flash_Current_Rerovery=false
        fi
    fi

    my_print "Do you want to install the built-in DFE-NEO Magisk v${MAGISK_VER}?"
    MYSELECT "YES" "NO"
    if [ $? = 1 ]; then
        Flash_Magisk=true
    else
        Flash_Magisk=false
    fi

    my_print "Do you want to hide the disabled encryption of the device? For example, the device settings will show that your device is encrypted, but in fact it is decrypted"
    MYSELECT "NOT HIDDEN" "HIDDEN" "The system will detect that your phone has been decrypted" "The system will display that your phone is encrypted. for more stability"
    if [ $? = 2 ]; then
        Hide_No_Encryption=true
    else
        Hide_No_Encryption=false
    fi
    my_print "Do you want to configure additional features?"
    MYSELECT "YES" "NO"
    if [ $? = 1 ]; then

        my_print "Enable in-built DFE-NEO Safetynet fix?"
        MYSELECT "ENABLE" "DISABLE"
        if [ $? = 1 ]; then
            safetyfix=true
        else
            safetyfix=false
        fi

        if $Flash_Magisk; then
            my_print "Force to enable zygisk mode for magisk at system startup? After installing DFE-NEO, zygisk mode for magisk will be permanently enabled, to turn it off, you will need to flash DFE-NEO without this mode"
            MYSELECT "YES" "NO"
            if [ $? = 1 ]; then
                force_zygisk=true
            else
                force_zygisk=false
            fi
        fi

        my_print "Add custom packages/applications automatically to denylist after system boot? The zygisk mode must be enabled. Packages in denylist.txt : $(wc -l $tmp/denylist.txt | awk '{print $1}')"
        MYSELECT "YES" "NO"
        if [ $? = 1 ]; then
            add_deny_list=true
        else
            add_deny_list=false
        fi

        my_print "Skip the mini tutorial on proper use after installation?"
        MYSELECT "NOT SKIP" "SKIP"
        if [ $? = 1 ]; then
            skip_warning=false
        else
            skip_warning=true
        fi

        my_print "Do wipe data after successful installation?"
        MYSELECT "DONT WIPE" "WIPE DATA" \
            "If your device has already been decrypted and you are updating the ROM" \
            "if your device is already decrypted and you change the ROM"
        if [ $? = 1 ]; then
            wipe_data=false
        else
            wipe_data=true

        fi

        if ! $wipe_data && [[ -f /data/system/locksettings.db ]] && ! $my_magisk_installer; then
            my_print "Do you want to remove the lockscreen pin?"
            MYSELECT "RETAIN TOUCH PIN" "REMOVE PIN"
            if [ $? = 1 ]; then
                rem_lock=false
            else
                rem_lock=true
            fi
        fi

        my_print "Restart the device after a successful installation?"
        MYSELECT4 "DONT RESTART" "SYSTEM" "RECOVERY" "BOOTLOADER/FASTBOOT"
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

        my_print "Do you want to disable the dynamic refresh rate of the display? Only for MIUI"
        MYSELECT "DISABLE DYNAMIC REFRESH RATE" "RETAIN DYNAMIC REFRESH RATE"
        if [ $? = 1 ]; then
            dynamic120hz=true
        else
            dynamic120hz=false
        fi
    fi

    ;;
esac

if ! $Flash_Magisk &&
    ! $Hide_No_Encryption &&
    ! $Flash_DFE &&
    ! $Reflash_Recovery_After_Oat &&
    ! $Flash_Current_Rerovery; then
    my_abort 71
fi


timer_start2=$(date +%s%N)
my_print "Starting the installation with these parameters:"

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
