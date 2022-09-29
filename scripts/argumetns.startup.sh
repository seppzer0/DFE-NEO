#!/sbin/sh
. $tmp/LNG/english.sh

magisk_ver_install="magisk-zips/stable-25.2-25200"


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
        my_print "$text105}"
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
if ! (mygrep_arg "Force reading arguments.txt" | grep -q "true"); then

    if $my_magisk_installer && [ -d /data/data/com.termux/ ] && ! [ "$4" == "termux" ]; then
        {
            MYSELECT \
                "$text107" \
                "$text108:select:$text24:comment:$text110" \
                "$text109:select:$text33:comment:$text111"
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
[ -z "$slot_ab" ] || my_print "$text15: $slot_ab"

read_argumetns_file
if (mygrep_arg "Force reading arguments.txt" | grep -q "true"); then
    first_select=2
else
    ui_print " "
    my_print "$text121"
    reset_arguments
    read_argumetns_file
    show_arguments
    ui_print " "
    my_print "$text5"
    my_print "$text6"
    {
        MYSELECT \
            "$text16" \
            "$text104" \
            "$text19"
    } && first_select=1 || first_select=2
fi
case $first_select in
2) sleep 0.1 ;;
1)
    reset_arguments

    {
        MYSELECT \
            "$text20" \
            "Install NEO method:select:DFE-NEO:comment:$text21" \
            "Install Legacy method:select:DFE-LEGACY:comment:$text22"
    } && legacy_mode=false || legacy_mode=true

    MYSELECT \
        "Which version of magisk-init, as well as in case of installing magisk built into dfe, to use to install/patch the boot image" \
        "Use MAGISK STABLE v25.2 OFFICIAL:select:25.2-S:comment:The official latest stable version of magisk" \
        "Use MAGISK STABLE v24.2  OFFICIAL:select:24.3-S:comment:The official old stable version of magisk" \
        "Use MAGISK ALPHA 555a54ec-25203:select:25.2-A:comment:Maybe official alpha" \
        "Use MAGISK DELTA-STABLE v25.2:select:25.2-D:comment:Unofficial" \
        "Use MAGISK DELTA ALPHA 91fa08ee-25203:select:25.2-D:comment:Unofficial"
    case $? in
    1) magisk_ver_install="magisk-zips/stable-25.2-25200" ;;
    2) magisk_ver_install="magisk-zips/stable-24.3-24300" ;;
    3) magisk_ver_install="magisk-zips/alpha-555a54ec-25203" ;;
    4) magisk_ver_install="magisk-zips/delta-25.2-25200" ;;
    5) magisk_ver_install="magisk-zips/delta-91fa08ee-25203" ;;
    esac

    {
        MYSELECT \
            "$text23" \
            "$text25" \
            "$text24"
    } && {
        AVB_STAY=true
        QUOTA_STAY=true
    } || {
        {
            MYSELECT \
                "$text26" \
                "$text33" \
                "$text24"
        } && QUOTA_STAY=false || QUOTA_STAY=true
        {
            MYSELECT \
                "$text29" \
                "$text33" \
                "$text24"
        } && AVB_STAY=false || AVB_STAY=true
    }
    $my_magisk_installer && {
        {
            MYSELECT \
                "$text32" \
                "$text24" \
                "$text33"
        } && Reflash_Recovery_After_Oat=true || Reflash_Recovery_After_Oat=false
    } || {
        {
            MYSELECT \
                "$text34" \
                "$text24" \
                "$text33"
        } && Flash_Current_Rerovery=true || Flash_Current_Rerovery=false
    }
    {
        MYSELECT \
            "$text35${MAGISK_VER}?" \
            "$text24" \
            "$text33"
    } && Flash_Magisk=true || Flash_Magisk=false
    {
        MYSELECT \
            "$text36" \
            "$text40:comment:$text38" \
            "$text39:comment:$text37"
    } && Hide_No_Encryption=false || Hide_No_Encryption=true
    {
        MYSELECT \
            "$text41" \
            "$text24" \
            "$text33"
    } && {
        $Flash_Magisk && {
            MYSELECT \
                "$text115" \
                "$text116:select:$text24" \
                "$text117:select:$text33"
        } && safetyfix=true || safetyfix=false
        $Flash_Magisk && {
            MYSELECT \
                "$text125" \
                "FORCE ENABLE ZYGISK:select:$text24" \
                "DISABLE FORCE ZYGISK:select:$text33"
        } && force_zygisk=true || force_zygisk=false
        $Flash_Magisk && {
            MYSELECT \
                "$text124 $(wc -l $tmp/denylist.txt | awk '{print $1}')" \
                "ENABLE CUSTOM DENYLIST:select:$text24" \
                "NOT YET:select:$text33"
        } && add_deny_list=true || add_deny_list=false
        {
            MYSELECT \
                "$text42" \
                "$text44:select:$text33" \
                "$text43:select:$text24"
        } && skip_warning=false || skip_warning=true
        {
            MYSELECT \
                "$text48" \
                "$text50:select:$text33:comment:$text52" \
                "$text49:select:$text24:comment:$text51"
        } && wipe_data=false || wipe_data=true
        (! $wipe_data && [ -f /data/system/locksettings.db ] && ! $my_magisk_installer) && {
            MYSELECT \
                "$text45" \
                "$text47:select:$text33" \
                "$text46:select:$text24"
        } && rem_lock=false || rem_lock=true
        {
            MYSELECT \
                "$text58" \
                "$text59:select:$text24" \
                "$text60:select:$text33"
        } && dynamic120hz=true || dynamic120hz=false
        MYSELECT \
            "$text53" \
            "$text54:select:$text33" \
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

my_print "$text61"

show_arguments


