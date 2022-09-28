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
