#!/sbin/sh

#SKIPUHNZIP=1
timer_start1=$(date +%s%N)
LNGarg="$5"
DFENV="1.5.3.014-BETA"
A_only=false
tmp="/dev/dfe-neo"
my_log="$tmp/log.neo-installer.$DFENV.txt"
sysboot=$(getprop sys.boot_completed)
CPU=$(getprop ro.product.cpu.abi)
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


# Create tmp folder

rm -rf $tmp
mkdir -pv $tmp &>$$my_log

# CPU and slot check

[ -z "$CPU" ] && my_abort 77
 
#leegar.print
my_print(){
# Задаю переменные
in_text="$1" # Передача всех символом в функцию
skipG="* "
tick=1
listT=0
all_char="${#in_text}" # Подсчет всех символов которые передаются в функцию
all_words2=$( 
    # Подсчет слов
    for word in $in_text; do listT=$((listT + 1)); done
    echo $((listT + 2))
) 

# Специальный аргумент для отмены симовла -, другими словами убирает первую линию и переходит сразу ко второй
! [ -z "$2" ] && [ "$2" = "selected" ] && first_line=false || first_line=true 

# Проверка на количество символов в тексте, если больше 50, то срабатывает обработчик, если меньше, то выводит текста сразу
if [ "$all_char" -gt 50 ]; then
    while true; do
        num=$(echo ${in_text%${in_text#$skipG}*} | wc -m)
        if [ "$num" -ge 45 ]; then
            [ "$num" -gt 55 ] && skipG="${skipG%\**}"
            $first_line && ui_print "- ${in_text%${in_text#$skipG}*}" || ui_print "  ${in_text%${in_text#$skipG}*}"
            in_text="${in_text#$skipG}"
            skipG="* "
            first_line=false
        else
            skipG="${skipG}* "
        fi
        tick=$((tick + 1))
        if [ "$tick" -ge "$all_words2" ]; then
            if [ -z "${in_text}" ] || [ "${in_text}" == " " ]; then
                ui_print " " && break
            else
                $first_line && ui_print "- ${in_text}" || ui_print "  ${in_text}"
            fi
            break
        fi
    done
else
    if [ -z "${in_text}" ] || [ "${in_text}" == " " ]; then
        ui_print " "
    else
        $first_line && ui_print "- ${in_text}" || i_print "  ${in_text}"
    fi
fi
} 
#chainfire.ianmacd.chooseport
chooseport() {
    # Original idea by chainfire and ianmacd @xda-developers
    [ "$1" ] && local delay=$1 || local delay=3
    local error=false
    while true; do
        local count=0
        while true; do
            timeout 0.5 /system/bin/getevent -lqc 1 2>&1 >$tmp/events &
            sleep 0.1
            count=$((count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $tmp/events); then
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $tmp/events); then
                return 1
            fi
            [ $count -gt 100 ] && break
        done
        if $error; then
            ui_print "$text119"
            exit 90
        else
            error=true
            ui_print " "
            ui_print "$text120"
        fi
    done
} 
#leegar.abort
my_abort() {
    error_code="$1"
    error_text="$2"

    if ! [ -z "$error_text" ]; then
        ui_print "*******************************"
        ui_print "*******************************"
        ui_print " "
        my_print "$2"
        ui_print " "
        ui_print "*******************************"
        ui_print "*******************************"
    fi
    my_print "$text1 $error_code"
    exit $error_code
} 
#leegar.grep.calc
mygrep_prop() { grep "$1" "$2" | sed 's|'"$1"'=||'; }
mygrep_arg() { grep "$1" "$tmp/arguments.txt" | sed 's|'"$1"'=||' ; }
calc() { awk 'BEGIN{ print int('"$1"') }'; }
calcF() { awk 'BEGIN{ print '"$1"' }'; } 
#leegar.read.arguments

read_argumetns_file() {
    mygrep_arg "Skip warnin" | grep -q "true" &&
        skip_warning=true || skip_warning=false

    mygrep_arg "DFE method" | grep -q "legacy" &&
        legacy_mode=true || legacy_mode=false

    mygrep_arg "Flash Magisk" | grep -q "true" &&
        Flash_Magisk=true || Flash_Magisk=false

    mygrep_arg "Hide No Encryption" | grep -q "true" &&
        Hide_No_Encryption=true || Hide_No_Encryption=false

    mygrep_arg "Reflash Recovery for OTA" | grep -q "true" &&
        Reflash_Recovery_After_Oat=true || Reflash_Recovery_After_Oat=false

    mygrep_arg "Reflash current Recovery for Recovery" | grep -q "true" &&
        Flash_Current_Rerovery=true || Flash_Current_Rerovery=false

    mygrep_arg "Hide not encrypted" | grep -q "true" &&
        Hide_No_Encryption=true || Hide_No_Encryption=false

    mygrep_arg "DISABLE DYNAMIC REFRESHRATE" | grep -q "true" &&
        dynamic120hz=true || dynamic120hz=false

    mygrep_arg "Wipe DATA" | grep -q "true" &&
        wipe_data=true || wipe_data=false

    mygrep_arg "Remove PIN" | grep -q "true" &&
        rem_lock=true || rem_lock=false

    mygrep_arg "Disable QUOTA" | grep -q "true" &&
        QUOTA_STAY=true || QUOTA_STAY=false

    mygrep_arg "Disable AVB" | grep -q "true" &&
        AVB_STAY=true || AVB_STAY=false

    mygrep_arg "Reboot after installing" | grep -q "system" &&
        rebootARG=system && rebootafter=true

    mygrep_arg "Reboot after installing" | grep -q "bootloader" &&
        rebootARG=bootloader && rebootafter=true

    mygrep_arg "Reboot after installing" | grep -q "recovery" &&
        rebootARG=recovery && rebootafter=true

    mygrep_arg "Safetynet fix" | grep -q "true" &&
        safetyfix=true || safetyfix=false

    mygrep_arg "Force Zygisk mode" | grep -q "true" &&
        force_zygisk=true || force_zygisk=false

    mygrep_arg "Add castom packages automatic in denylist" | grep -q "true" &&
        add_deny_list=true || add_deny_list=false
}

show_arguments() {

    $force_zygisk && ! $legacy_mode
    my_print ">>> Forced zygisk mode (DEFAULT)" "selected"
    $add_deny_list && ! $legacy_mode &&
        my_print ">>> Add apps to denylist automatically (DEFAULT)" "selected"
    $Flash_DFE && ! $legacy_mode &&
        my_print ">>> DFE-NEO (DEFAULT)" "selected"
    $Flash_DFE && $legacy_mode &&
        my_print ">>> DFE LEGACY (DEFAULT)" "selected"
    $Flash_Magisk &&
        my_print ">>> Flash Magisk (DEFAULT)" "selected"
    $Hide_No_Encryption &&
        my_print ">>> Hide not encrypted" "selected"
    $Reflash_Recovery_After_Oat && $my_magisk_installer &&
        my_print ">>> Reflash recovery after OTA" "selected"
    $Flash_Current_Rerovery && ! $my_magisk_installer &&
        my_print ">>> Reflash current Recovery" "selected"
    $rem_lock && ! $my_magisk_installer &&
        my_print ">>> Remove lock pin" "selected"
    $wipe_data &&
        my_print ">>> Wiping DATA" "selected"
    $QUOTA_STAY &&
        my_print ">>> Remove quota (DEFAULT)" "selected"
    $safetyfix &&
        my_print ">>> Safetynet fix (DEFAULT)" "selected"
    $AVB_STAY &&
        my_print ">>> Remove avb (DEFAULT)" "selected"
    $rebootafter &&
        my_print ">>> Reboot after install to: $rebootARG" "selected"
    if $dynamic120hz && ! $legacy_mode; then
        my_print ">>> Disable dynamic refresh rate" "selected"
    fi
}

reset_arguments() {
    rebootARG=""

    wipe_data=false
    rem_lock=false
    skip_warning=false
    dynamic120hz=false
    rebootafter=false
    Reflash_Recovery_After_Oat=false
    Flash_Current_Rerovery=false
    Hide_No_Encryption=false
    legacy_mode=false

    AVB_STAY=true
    QUOTA_STAY=true
    safetyfix=true
    Flash_DFE=true
    Flash_Magisk=true
    add_deny_list=true
    force_zygisk=true
}
 
#leegar.selecters
MYSELECT() {
    ui_print ""
    [ -z "$1" ] || my_print "$1"
    ui_print ""
    tick_for=1
    for text in "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}" "${13}" "${14}" "${15}"; do
        [ -z "$text" ] && break
        text_input=${text%:comment:*}
        text_select=${text_input#*:select:}
        text_input=${text_input%:select:*}
        text_commend=${text#*:comment:}

        my_print "${tick_for}) [$text_input]" "selected"
        (echo $text | grep -q ':comment:') && my_print "--${text_commend}--" "selected"
        [ -z "$text_for_select" ] &&
            text_for_select="${tick_for}) $text_select" ||
            text_for_select="${text_for_select}\n${tick_for}) ${text_select}"
        tick_for=$((tick_for + 1))
    done

    text_for_select="${text_for_select}\n${text4}"

    tick_select=1
    all_ticks=$(echo -e $text_for_select | wc -l)
    while true; do
        my_print " > $(echo -e $text_for_select | head -n$tick_select | tail -n1) <" "selected"
        if chooseport 60; then
            tick_select=$((tick_select + 1))
        else
            break
        fi
        if [ $tick_select -gt $all_ticks ]; then
            tick_select=1
        fi
    done
    my_print " >[$(echo -e $text_for_select | head -n$tick_select | tail -n1)]<" "selected"
    ui_print " "
    ui_print "**==================================***"
    if [ "$(echo -e $text_for_select | head -n$tick_select | tail -n1)" = "${text4}" ]; then
        my_abort "1"
    fi
    if [ $all_ticks -le 3 ]; then
        [ $tick_select = 1 ] && return 0
        [ $tick_select = 2 ] && return 1
    else
        return $tick_select
    fi
}

 
#leegar.dfe
tabul="
"
DFE() {
    fstabp=$1
    g=$(
        echo "fileencryption="
        echo "forcefdeorfbe="
        echo "encryptable="
        echo "forceencrypt="
        echo "metadata_encryption="
        echo "keydirectory="
        $AVB_STAY && echo "avb="
        $AVB_STAY && echo "avb_keys="
    )
    g2=$(
        $AVB_STAY && echo "avb"
        $QUOTA_STAY && echo "quota"
        echo "inlinecrypt"
        echo "wrappedkey"
    )
    while ($(
        for i in $g; do grep -q "$i" $fstabp && return 0
        done
        return 1
    )); do
        fstabp_now=$(cat "$fstabp")
        for remove in $g; do
            grep -q "$remove" "$fstabp" &&
                remove_now="${fstabp_now#*"$remove"}" &&
                remove_now="${remove_now%%,*}" &&
                remove_now="${remove}${remove_now%%"$tabul"*}" ||
                continue
            grep -q ",$remove_now" "$fstabp" &&
                sed -i 's|,'$remove_now'||' $fstabp
            grep -q "$remove_now" "$fstabp" &&
                sed -i 's|'$remove_now'||' $fstabp
        done
    done
    if ($(
        for i in $g2; do
            grep -q "$i" $fstabp && return 0
        done
        return 1
    )); then
        for remove in $g2; do
            grep -q ",$remove" $fstabp && sed -i 's|,'$remove'||g' $fstabp
            grep -q "$remove," $fstabp && sed -i 's|'$remove',||g' $fstabp
            grep -q "$remove" $fstabp && sed -i 's|'$remove'||g' $fstabp
        done
    fi
} 
#leegar.mount
rw_part_check() {
    mnt="$1"
    echo "test test test TEST TESTR TEST" &>$mnt/test.txt
    if [[ $(stat -c%s $mnt/test.txt) -ge 6 ]]; then
        rm -f $mnt/test.txt
        return 0
    else
        [[ -f $mnt/test.txt ]] && rm -f $mnt/test.txt
        return 1
    fi
}

mount_part() {
    for mnt in vendor $($my_magisk_installer && echo system || echo system_root) odm system_ext product; do
        case "$1" in
        --mount)
            if ! $my_magisk_installer; then
                umount /$mnt
                e2fsck -f /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                blockdev --setrw /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                e2fsck -E unshare_blocks -y -f /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                resize2fs /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                mount /$mnt
            fi
            mount -o rw,remount /$mnt
            $my_magisk_installer && mount -o rw,remount /
            ;;
        --umount)
            (mountpoint -q /$mnt) && umount /$mnt
            ;;
        esac
    done
}
 
#unpacking.tool

my_print "Unpacking tools"
cd $tmp
# Unpack busybox
mkdir -pv "$tmp/my_BB"
mkdir -pv "$tmp/my_bins"
unzip -o "$arg3" "tools/busybox.zip" -d "$tmp"/
unzip -o "$tmp/tools/busybox.zip" -d "$tmp"/my_BB/
BB=""
chmod 777 $tmp/my_BB/*

# Find busybox for arch
{
    "$tmp"/my_BB/busybox-x86_64 &&
        BB="$tmp/my_BB/busybox-x86_64" &&
        MB="$tmp/magiskboot/magiskboot-x86_64" &&
        little_arch="x86" &&
        big_arch="x86_64"
} ||
    {
        "$tmp"/my_BB/busybox-x86 &&
            BB="$tmp/my_BB/busybox-x86" &&
            MB="$tmp/magiskboot/magiskboot-x86" &&
            little_arch="x86" &&
            big_arch="x86"
    } ||
    {
        "$tmp"/my_BB/busybox-arm64 &&
            BB="$tmp/my_BB/busybox-arm64" &&
            MB="$tmp/magiskboot/magiskboot-arm64" &&
            little_arch="armeabi-v7a" &&
            big_arch="arm64-v8a"
    } ||
    {
        "$tmp"/my_BB/busybox-arm &&
            BB="$tmp/my_BB/busybox-arm" &&
            MB="$tmp/magiskboot/magiskboot-arm" &&
            little_arch="armeabi-v7a" &&
            big_arch="armeabi-v7a"
    } ||
    my_abort "75" "Cant find busybox arch"

cp "$BB" "$tmp/my_bins/busybox"
BB=$tmp/my_bins/busybox
chmod 777 "$BB"

# Unpack dfe-neo.zip
mkdir -pv "$tmp/LNG"

$BB unzip -o "$arg3" \
    "arguments.txt" \
    "denylist.txt" \
    "tools/bootctl" \
    "tools/magiskboot.zip" \
    "tools/magisklite25.2.zip" \
    "tools/others.magisk.files.zip" \
    "tools/init.rc" \
    "tools/magisk.db" \
    "tools/init.sh" \
    "tools/sql" \
    -j -d $tmp/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"

# unpack languages
$BB unzip -o "$arg3" \
    "languages/*.sh" \
    -j -d $tmp/LNG/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"

# Magiksboot unpack
mkdir -pv "$tmp/magiskboot"
$BB unzip -o "$tmp/magiskboot.zip" -j -d $tmp/magiskboot/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
cp "$MB" "$tmp/my_bins/magiskboot"
MB="$tmp/my_bins/magiskboot"
chmod 777 "$MB"
mv "$tmp/bootctl" "$tmp/my_bins/bootctl"
PATH=$tmp/my_bins:$PATH

[ -f $BB ] || my_abort 63

chmod 777 $tmp/my_bins/*

# Slot detected
slot_num=$(bootctl get-current-slot)
slot_ab=$(bootctl get-suffix $slot_num)
if ! [ "$(getprop ro.virtual_ab.enabled)" = "true" ]; then A_only=true; fi
if $A_only; then
    sleep 0.1
elif [[ $slot_ab == "_a" ]]; then
    not_slot_ab="_b"
elif [[ $slot_ab == "_b" ]]; then
    not_slot_ab="_a"
else
    slot_ab=""
    not_slot_ab=""
fi


 
#argumetns.startup
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
 
#unpacking.magisk
# Magisk unzip

export BBBIN="$BB"
# unzip chromeos and others
$BB unzip -o "$tmp/others.magisk.files.zip" -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
export INSTALLER="$tmp/my_bins"
$BB unzip -o "$tmp/$magisk_ver_install.zip" "assets/*" -d $INSTALLER &>"$my_log" || my_abort "44" "Cant unzip $arg3"
$BB mv "$INSTALLER/assets/*" "$INSTALLER/"
# $INSTALLER/magiskboot{arch}:busybox{arch}:bootctl{all}:all files in assets folder

export ASH_STANDALONE=1

$BB unzip -o "$tmp/$magisk_ver_install.zip" "lib/$big_arch" -j -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
if ! [ $little_arch = $big_arch ] ; then 
$BB unzip -o "$tmp/$magisk_ver_install.zip" "lib/$little_arch/libmagisk32.so" -j -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
fi
for file in $INSTALLER/lib*.so ; do
$BB mv $file $( dirname $file )$( basename $file | sed 's|lib||' | sed 's|.so||' )
done
# $INSTALLER/magiskboot{arch}:busybox{arch}:bootctl{all}:magisk32/64:magiskinit:magiskpolicy:all files in assets folder

umask 022
OUTFD=$2
APK="$tmp/$magisk_ver_install.zip"
COMMONDIR=$INSTALLER
CHROMEDIR=$INSTALLER/chromeos

[ -f $COMMONDIR/util_functions.sh ] || my_abort "7" "! Unable to extract zip file!"

# Backup magisk scripts
mkdir -pv $tmp/magisk_files_tmp
$BB cp -af $COMMONDIR/* $tmp/magisk_files_tmp/

for file in $COMMONDIR/*.sh; do
    sed -i 's|ui_print "|echo "|' $file
done

. $COMMONDIR/util_functions.sh
get_flags &>"$my_log"
api_level_arch_detect &>"$my_log"
if echo $MAGISK_VER | grep -q '\.'; then
    PRETTY_VER=$MAGISK_VER
else
    PRETTY_VER="$MAGISK_VER"
fi

api_level_arch_detect &>"$my_log"
BINDIR=$INSTALLER
cd $BINDIR || my_abort "3"

chmod -R 755 $BINDIR
rm -rf $MAGISKBIN/* &>$(dirname $arg3)/log.txt
mkdir -p $MAGISKBIN &>$(dirname $arg3)/log.txt
cp -af $BINDIR/* $MAGISKBIN/
#cp -af $BINDIR/. $tmp/magisk_files_tmp/* $BBBIN $MAGISKBIN
chmod -R 755 $MAGISKBIN
cd $tmp || my_abort "3" 
#patching.boot


if $legacy_mode && $Flash_DFE; then
    stop_dfe=false
    for file in /data/gsi/ota/*.img; do
        [[ -f $file ]] && stop_dfe=true
    done
    $stop_dfe && my_abort "98" "Cant mount partition, please reboot recovery or try neo method"

    mount_part --mount
    if ! $my_magisk_installer && ! (mountpoint -q /vendor) && ! (mountpoint -q /system_root); then
        my_abort "88" "$text75"
    fi
    for file in $(find $($my_magisk_installer && echo /system || echo /system_root) /system_ext /odm /product /vendor -name "*fstab*"); do
        if (grep -q "/userdata" $file) && (grep -q "/metadata" $file); then
            rw_part_check "$(dirname "$file")" || my_abort "74" "Your system have RO status, please use MakeRW or SystemRW or use neo method"
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





ui_print " "
for forslot in $(
    if $A_only; then
        echo "A_only"
    elif (echo $(mygrep_prop "Flash SLOT" $tmp/arguments.txt) | grep -q "in-current"); then
        echo $slot_ab
    elif (echo $(mygrep_prop "Flash SLOT" $tmp/arguments.txt) | grep -q "un-current"); then
        echo $not_slot_ab
    else
        echo $slot_ab $not_slot_ab
    fi
); do
    {
        mkdir $tmp/current_boot$forslot
        tmp_boot=$tmp/current_boot$forslot
        ! $my_magisk_installer && mount_part --umount

        if [[ $forslot == "A_only" ]]; then
            BOOTIMAGE=
            if $RECOVERYMODE; then
                BOOTIMAGE=$(find_block "recovery_ramdisk$SLOT" "recovery$SLOT" "sos")
            elif [ ! -z $SLOT ]; then
                BOOTIMAGE=$(find_block "ramdisk$SLOT" "recovery_ramdisk$SLOT" "init_boot$SLOT" "boot$SLOT")
            else
                BOOTIMAGE=$(find_block ramdisk recovery_ramdisk kern-a android_boot kernel bootimg init_boot boot lnx boot_a)
            fi
            if [ -z $BOOTIMAGE ]; then
                # Lets see what fstabs tells me
                BOOTIMAGE=$(grep -v '#' /etc/*fstab* | grep -E '/boot(img)?[^a-zA-Z]' | grep -oE '/dev/[a-zA-Z0-9_./-]*' | head -n 1)
            fi
        else
            SLOT=$forslot
            find_boot_image
        fi
        boot=$BOOTIMAGE
        #boot=/storage/emulated/0/Download/boot.img
        #BOOTIMAGE=/storage/emulated/0/Download/boot.img
        [[ -z $boot ]] && my_abort 4
        cd $tmp_boot
        magiskboot unpack -h $boot &>$(dirname $arg3)/log.txt

        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_64" &&
            magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_64"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_32" &&
            magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_32"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/init.dfe.sh" &&
            magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/init.dfe.sh"
        magiskboot cpio ramdisk.cpio "exists overlay.d/init.dfe.rc" &&
            magiskboot cpio ramdisk.cpio "rm overlay.d/init.dfe.rc"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/dfe_neo_support_binary" &&
            magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/dfe_neo_support_binary"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/dfe.neo.magisk.lib.txt" &&
            magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/dfe.neo.magisk.lib.txt"

        if $Flash_Current_Rerovery && ! $my_magisk_installer && ! [ $forslot = "A_only" ]; then
            ! $my_magisk_installer && mount_part --umount
            ramdisk_files=$(find / -maxdepth 1 -type f -name "*ramdisk-files*" -and -not -name "*.txt")
            cd /
            if (sha256sum --status -c "$ramdisk_files"); then
                my_print "$text112 $($A_only || echo $text78 $forslot)"
                cd $tmp_boot || my_abort "3"
                rm -f ramdisk.cpio
                cd /
                cpio -H newc -o </ramdisk-files.txt >$tmp_boot/ramdisk.cpio
                cd $tmp_boot || my_abort "3"

                #magiskboot repack /dev/block/by-name/boot$forslot &>$(dirname $arg3)/log.txt

                #flash_image \
                #    "$tmp/recovery$forslot/new-boot.img" \
                #    "/dev/block/by-name/boot$forslot"

                cd $tmp || my_abort "3"
                #rm -rf $tmp/recovery$forslot
            else
                my_abort "65" "$text76"
            fi
        fi
        if $Reflash_Recovery_After_Oat && $my_magisk_installer && ! [ $forslot = "A_only" ]; then
            if [[ $forslot == $not_slot_ab ]]; then
                mkdir -pv $tmp/recovery$slot_ab &>$(dirname $arg3)/log.txt
                cd $tmp/recovery$slot_ab || my_abort "3"
                magiskboot unpack -h /dev/block/by-name/boot$slot_ab &>$(dirname $arg3)/log.txt
                rm -f $tmp_boot/ramdisk.cpio

                mv \
                    $tmp/recovery$slot_ab/ramdisk.cpio \
                    $tmp_boot/ramdisk.cpio
                cd $tmp || my_abort "3"
            fi
        fi

        if $Flash_Magisk; then
            cp $MAGISKBIN/* $tmp_boot/
            chmod -R 755 $tmp_boot
            my_print "$text77$MAGISK_VER $($A_only || echo $text78 $forslot)"
            BOOTIMAGE=$boot
            cd $tmp_boot
            sed -i 's|cd|#cd|' $tmp_boot/boot_patch.sh
            sed -i 's|./magiskboot unpack|#./magiskboot unpack|' $tmp_boot/boot_patch.sh
            sed -i 's|./magiskboot repack|#./magiskboot repack|' $tmp_boot/boot_patch.sh
            if [ ! -c $BOOTIMAGE ]; then
                eval $BOOTSIGNER -verify <$BOOTIMAGE && BOOTSIGNED=true
                $BOOTSIGNED && ui_print "- Boot image is signed with AVB 1.0"
            fi

            # Source the boot patcher
            SOURCEDMODE=true
            . ./boot_patch.sh "$BOOTIMAGE" &>$(dirname $arg3)/log.txt
            case $? in
            1)
                abort "! Insufficient partition size"
                ;;
            2)
                abort "! $BOOTIMAGE is read only"
                ;;
            esac
            run_migrations &>$(dirname $arg3)/log.txt
            cd $tmp || my_abort "3"
        fi

        if $Flash_DFE && ! $legacy_mode; then
            my_print "$text79 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
            cd $tmp_boot || my_abort "3"
            magiskboot cpio ramdisk.cpio test &>$(dirname $arg3)/log.txt
            STATUSM=$?
            if [[ $STATUSM == 0 ]] ||
                ( ! (magiskboot cpio ramdisk.cpio \
                    "exists overlay.d/sbin/magisk64.xz" &>$(dirname $arg3)/log.txt) ||
                    ! (magiskboot cpio ramdisk.cpio \
                        "exists overlay.d/sbin/magisk32.xz" &>$(dirname $arg3)/log.txt)); then
                STATUSM=0
            fi
            case $STATUSM in
            1)
                my_print "$text80 $($A_only || echo $text78 $forslot)"
                my_print "$text81 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
                magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" &&
                    echo magisk64 >>dfe.neo.magisk.lib.txt
                magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" &&
                    echo magisk32 >>dfe.neo.magisk.lib.txt
                ;;
            0)
                my_print "$text82 $($A_only || echo $text78 $forslot)"
                my_print "$text83 $($A_only || echo $text78 $forslot)"
                cp $MAGISKBIN/* $tmp_boot/
                chmod -R 755 $tmp_boot
                BOOTIMAGE=$boot
                cd $tmp_boot
                sed -i 's|cd|#cd|' $tmp_boot/boot_patch.sh
                sed -i 's|./magiskboot unpack|#./magiskboot unpack|' $tmp_boot/boot_patch.sh
                sed -i 's|./magiskboot repack|#./magiskboot repack|' $tmp_boot/boot_patch.sh
                if [ ! -c $BOOTIMAGE ]; then
                    eval $BOOTSIGNER -verify <$BOOTIMAGE && BOOTSIGNED=true
                    $BOOTSIGNED && ui_print "- Boot image is signed with AVB 1.0"
                fi

                # Source the boot patcher
                SOURCEDMODE=true
                . ./boot_patch.sh "$BOOTIMAGE" &>$(dirname $arg3)/log.txt
                case $? in
                1)
                    abort "! Insufficient partition size"
                    ;;
                2)
                    abort "! $BOOTIMAGE is read only"
                    ;;
                esac
                run_migrations &>$(dirname $arg3)/log.txt
                cd $tmp_boot || my_abort "3"
                my_print "$text85 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
                if (magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz"); then
                    magiskboot cpio ramdisk.cpio "extract overlay.d/sbin/magisk64.xz 64.xz"
                    magiskboot decompress 64.xz my_mg_64
                    echo magisk64 >>dfe.neo.magisk.lib.txt
                    magiskboot cpio ramdisk.cpio "add 0750 overlay.d/sbin/my_mg_64 my_mg_64"
                fi
                if (magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk32.xz"); then
                    magiskboot cpio ramdisk.cpio "extract overlay.d/sbin/magisk32.xz 32.xz"
                    magiskboot decompress 32.xz my_mg_32
                    echo magisk32 >>dfe.neo.magisk.lib.txt
                    magiskboot cpio ramdisk.cpio "add 0750 overlay.d/sbin/my_mg_32 my_mg_32"
                fi
                magiskboot cpio ramdisk.cpio \
                    "rm overlay.d/sbin/magisk64.xz" \
                    "rm overlay.d/sbin/magisk32.xz" &>$(dirname $arg3)/log.txt

                ;;
            esac
            cd $tmp_boot
            unzip -o "$tmp/magisklite.zip" \
                "lib/$CPU/libmagisk64.so" -j -d $tmp_boot &>$(dirname $arg3)/log.txt
            unzip -o "$tmp/magisklite.zip" \
                "lib/$CPU/libmagisk32.so" -j -d $tmp_boot &>$(dirname $arg3)/log.txt
            [ -f $tmp_boot/libmagisk64.so ] && inject_my_magisk=$tmp_boot/libmagisk64.so
            [ -f $tmp_boot/libmagisk32.so ] && inject_my_magisk=$tmp_boot/libmagisk32.so
            magiskboot cpio ramdisk.cpio "exists .backup/.magisk" &>$(dirname $arg3)/log.txt &&
                magiskboot cpio ramdisk.cpio "extract .backup/.magisk fconfig" &>$(dirname $arg3)/log.txt
            (cat fconfig | grep -q "KEEPVERITY=true") &&
                sed -i 's|KEEPVERITY=true|KEEPVERITY=false|' fconfig
            (cat fconfig | grep -q "KEEPFORCEENCRYPT=true") &&
                sed -i 's|KEEPFORCEENCRYPT=true|KEEPFORCEENCRYPT=false|' fconfig
            magiskboot cpio ramdisk.cpio \
                "add 0750 overlay.d/sbin/init.dfe.sh $tmp/init.sh" \
                "add 0750 overlay.d/sbin/m.db $tmp/magisk.db" \
                "add 0750 overlay.d/sbin/sql $tmp/sql" \
                "add 0750 overlay.d/sbin/denylist.txt $tmp/denylist.txt" \
                "add 0750 overlay.d/sbin/dfe.neo.magisk.lib.txt dfe.neo.magisk.lib.txt" \
                "add 0750 overlay.d/sbin/dfe_neo_support_binary $inject_my_magisk" \
                "add 0750 overlay.d/init.dfe.rc $tmp/init.rc" \
                "add 000 .backup/.magisk fconfig" &>$(dirname $arg3)/log.txt
        fi
        cd $tmp_boot
        my_print "$text113 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
        magiskboot repack $boot &>$(dirname $arg3)/log.txt
        my_print "$text114 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
        flash_image ./new-boot.img $boot
        #cp ./new-boot.img /sdcard/boot$forslot.img
        rm -f ./new-boot.img ./kernel ./header ./ramdisk.cpio
        cd $tmp
    } &
done
wait
 
#ending
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
