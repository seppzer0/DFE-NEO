#!/sbin/sh
. $tmp/LNG/english.sh

if (echo $(mygrep_prop "Force reading arguments.txt" $tmp/arguments.txt) | grep -q "true"); then
    MYLNG=$(mygrep_prop "Language" $tmp/arguments.txt)
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
        my_print "{$text105}"
        my_print "$text17" "selected"
        my_print "$text18" "selected"
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
if ! (echo $(mygrep_prop "Force reading arguments.txt" $tmp/arguments.txt) | grep -q "true"); then
    if $my_magisk_installer && [[ -d /data/data/com.termux/ ]] && ! [[ $4 == termux ]]; then
        my_print "$text107"
        MYSELECT "$text108" "$text109" "$text110" "$text111"
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


my_print "$text11 $DFENV"
my_print "$text12"
my_print "$text13"
my_print "$text14"
#DEL="$MYSKIPP>> $( dirname $arg3 )/log.txt"

# Device A/B check


#sleep 1

my_print "$text8: $(getprop ro.build.product)"
my_print "$text9: $(getprop ro.product.model)"
my_print "$text10: $CPU"
my_print "$text15 $slot_ab"


if (echo $(mygrep_prop "Force reading arguments.txt" $tmp/arguments.txt) | grep -q "true"); then
    first_select=2
else
    ui_print " "
    my_print "$text16"
    my_print "$text121"
    $force_zygisk  && ! $legacy_mode
    my_print "$text122 $text126" "selected"
$add_deny_list  && ! $legacy_mode &&
    my_print "$text123 $text126" "selected"
$Flash_DFE && ! $legacy_mode &&
    my_print "$text62 $text126" "selected"
$Flash_DFE && $legacy_mode &&
    my_print "$text63 $text126" "selected"
$Flash_Magisk &&
    my_print "$text64 $text126" "selected"
$Hide_No_Encryption &&
    my_print "$text65" "selected"
$Reflash_Recovery_After_Oat && $my_magisk_installer &&
    my_print "$text66" "selected"
$Flash_Current_Rerovery && ! $my_magisk_installer &&
    my_print "$text67" "selected"
$rem_lock && ! $my_magisk_installer &&
    my_print "$text68" "selected"
$wipe_data &&
    my_print "$text69" "selected"
$QUOTA_STAY &&
    my_print "$text70 $text126" "selected"
$safetyfix &&
    my_print "$text118 $text126" "selected"
$AVB_STAY &&
    my_print "$text71 $text126" "selected"
$rebootafter &&
    my_print "$text72 $rebootARG" "selected"
if $dynamic120hz && ! $legacy_mode; then
    my_print "$text73" "selected"
fi
ui_print " "
    my_print "$text17"
    my_print "$text18"
    
    MYSELECT "$text104" "$text19"
    #"DFE-method=$legacy_mode, Flash-Magisk=$Flash_Magisk, Hide-No-Encryption=$Hide_No_Encryption, Reflash-Recovery-for-OTA=$Reflash_Recovery_After_Oat, Reflash-current-Recovery=$Flash_Current_Rerovery, DISABLE-DYNAMIC-REFRESHRATE=$dynamic120hz, Wipe-DATA=$wipe_data, Remove-PIN=$rem_lock, Disable-QUOTA=$QUOTA_STAY, Disable-AVB=$AVB_STAY, Reboot-after-installing=${rebootafter}-$rebootARG, Safetynet-fix=$safetyfix, Force-Zygisk-mode=$force_zygisk, Add-castom-packages-automatic-in-denylist=$add_deny_list"
    first_select=$?
fi
case $first_select in
2)
    sleep 0.1

    ;;
    1)

    #twrp install "/sdcard/Download/miuipro_v12.0_alioth_22.7.14.zip"
    my_print "$text20?"
    Flash_DFE=true
    MYSELECT "DFE-NEO" "DFE-LEGACY" "$text21" "$text22"
    if [ $? = 2 ]; then
        legacy_mode=true
    else
        legacy_mode=false
    fi

    my_print "$text23"
    MYSELECT "$text25" "$text24"
    if [ $? = 2 ]; then

        my_print "$text26"
        MYSELECT "$text27" "$text28"
        if [ $? = 1 ]; then
            QUOTA_STAY=true
        else
            QUOTA_STAY=false
        fi

        my_print "$text29"
        MYSELECT "$text30" "$text31"
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
        my_print "$text32"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            Reflash_Recovery_After_Oat=true
        else
            Reflash_Recovery_After_Oat=false
        fi
    else
        my_print "$text34"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            Flash_Current_Rerovery=true
        else
            Flash_Current_Rerovery=false
        fi
    fi

    my_print "${text35}${MAGISK_VER}?"
    MYSELECT "$text24" "$text33"
    if [ $? = 1 ]; then
        Flash_Magisk=true
    else
        Flash_Magisk=false
    fi

    my_print "$text36"
    MYSELECT "$text40" "$text39" "$text38" "$text37"
    if [ $? = 2 ]; then
        Hide_No_Encryption=true
    else
        Hide_No_Encryption=false
    fi
    my_print "$text41"
    MYSELECT "$text24" "$text33"
    if [ $? = 1 ]; then

        my_print "$text115"
        MYSELECT "$text116" "$text117"
        if [ $? = 1 ]; then
            safetyfix=true
        else
            safetyfix=false
        fi

        if $Flash_Magisk ; then
        my_print "$text125"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            force_zygisk=true
        else
            force_zygisk=false
        fi
        fi

        
        my_print "$text124 $(wc -l $tmp/denylist.txt | awk '{print $1}')"
        MYSELECT "$text24" "$text33"
        if [ $? = 1 ]; then
            add_deny_list=true
        else
            add_deny_list=false
        fi


        my_print "$text42"
        MYSELECT "$text44" "$text43"
        if [ $? = 1 ]; then
            skip_warning=false
        else
            skip_warning=true
        fi

        my_print "$text48"
        MYSELECT "$text50" "$text49" \
            "$text52" \
            "$text51"
        if [ $? = 1 ]; then
            wipe_data=false
        else
            wipe_data=true

        fi

        if ! $wipe_data && [[ -f /data/system/locksettings.db ]] && ! $my_magisk_installer; then
            my_print "$text45"
            MYSELECT "$text47" "$text46"
            if [ $? = 1 ]; then
                rem_lock=false
            else
                rem_lock=true
            fi
        fi

        my_print "$text53"
        MYSELECT4 "$text54" "$text55" "$text56" "$text57"
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

        my_print "$text58"
        MYSELECT "$text59" "$text60"
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

# Welcome ui
timer_start2=$(date +%s%N)
my_print "$text61"



$force_zygisk  && ! $legacy_mode
    my_print "$text122 $text126" "selected" || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} zygisk_on||g' "$tmp"/init.rc
}


$add_deny_list  && ! $legacy_mode &&
    my_print "$text123 $text126" "selected" || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} add_denylist||g' "$tmp"/init.rc
}

    
$Flash_DFE && ! $legacy_mode &&
    my_print "$text62 $text126" "selected"
$Flash_DFE && $legacy_mode &&
    my_print "$text63 $text126" "selected"
$Flash_Magisk &&
    my_print "$text64 $text126" "selected"
$Hide_No_Encryption &&
    my_print "$text65" "selected" ||
    sed -i 's|setprop ro.crypto.state encrypted||' "$tmp"/init.rc
$Reflash_Recovery_After_Oat && $my_magisk_installer &&
    my_print "$text66" "selected"
$Flash_Current_Rerovery && ! $my_magisk_installer &&
    my_print "$text67" "selected"

$rem_lock && ! $my_magisk_installer &&
    my_print "$text68" "selected"
$wipe_data &&
    my_print "$text69" "selected"

$QUOTA_STAY &&
    my_print "$text70 $text126" "selected"
! $QUOTA_STAY &&
    sed -i 's|echo "quota"|#echo "quota"|' "$tmp"/init.sh

$safetyfix &&
    my_print "$text118 $text126" "selected" || {

    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_fs||g' "$tmp"/init.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_init||g' "$tmp"/init.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_boot_complite||g' "$tmp"/init.rc
}

$AVB_STAY &&
    my_print "$text71 $text126" "selected"
! $AVB_STAY &&
    sed -i 's|echo "avb="|#echo "avb="|' "$tmp"/init.sh &&
    sed -i 's|echo "avb_keys="|#echo "avb_keys="|' "$tmp"/init.sh &&
    sed -i 's|echo "avb"|#echo "avb"|' "$tmp"/init.sh

$rebootafter &&
    my_print "$text72 $rebootARG" "selected"
if $dynamic120hz && ! $legacy_mode; then
    my_print "$text73" "selected" &&
        sed -i 's|#exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic|' "$tmp"/init.rc
fi
if $legacy_mode && $Flash_DFE; then
    stop_dfe=false
    for file in /data/gsi/ota/*.img; do
        [[ -f $file ]] && stop_dfe=true
    done
    $stop_dfe && my_abort "98" "$text74"

    mount_part --mount
    if ! $my_magisk_installer && ! (mountpoint -q /vendor) && ! (mountpoint -q /system_root); then
        my_abort "88" "$text75"
    fi
    for file in $(find $($my_magisk_installer && echo /system || echo /system_root) /system_ext /odm /product /vendor -name "*fstab*"); do
        if (grep -q "/userdata" $file) && (grep -q "/metadata" $file); then
            rw_part_check "$(dirname "$file")" || my_abort "74" "$text106"
        fi
    done
    for file in $(find $($my_magisk_installer && echo /system || echo /system_root) /system_ext /odm /product /vendor -name "*fstab*"); do
        if (grep -q "/userdata" $file) && (grep -q "/metadata" $file); then
            DFE "$file"
            my_print "$(basename $file) successfully patched"
        fi
    done
    if $Hide_No_Encryption; then
        if ! $my_magisk_installer && (rw_part_check "/system_root/system"); then
            (grep -q "ro.crypto.state" /system_root/system/build.prop &&
                sed -i '/ro.crypto.state/d' /system_root/system/build.prop &&
                echo "ro.crypto.state=encrypted" >>/system_root/system/build.prop) ||
                echo "ro.crypto.state=encrypted" >>/system_root/system/build.prop
        elif $my_magisk_installer && (rw_part_check "/system"); then
            (grep -q "ro.crypto.state" /system/build.prop &&
                sed -i '/ro.crypto.state/d' /system/build.prop &&
                echo "ro.crypto.state=encrypted" >>/system/build.prop) ||
                echo "ro.crypto.state=encrypted" >>/system/build.prop
        fi
    fi
fi