#!/sbin/sh

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

    case $( mygrep_arg "Base as magisk" ) in
    *stable-25.2-25200*) magisk_ver_install="magisk-zips/stable-25.2-25200" ;;
    *stable-24.3-24300*) magisk_ver_install="magisk-zips/stable-24.3-24300" ;;
    *alpha-555a54ec-25203*) magisk_ver_install="magisk-zips/alpha-555a54ec-25203" ;;
    *delta-25.2-25200*) magisk_ver_install="magisk-zips/delta-25.2-25200" ;;
    *delta-91fa08ee-25203*) magisk_ver_install="magisk-zips/delta-91fa08ee-25203" ;;
    esac
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
    my_print "$text122 $text126" "selected"
    $add_deny_list && ! $legacy_mode &&
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
    my_print ">>> Magisk base ${magisk_ver_install#*magisk-zips/}" "selected"
    $AVB_STAY &&
        my_print "$text71 $text126" "selected"
    $rebootafter &&
        my_print "$text72 $rebootARG" "selected"
    if $dynamic120hz && ! $legacy_mode; then
        my_print "$text73" "selected"
    fi
}

reset_arguments() {
    rebootARG=""
    magisk_ver_install="magisk-zips/stable-25.2-25200"
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
