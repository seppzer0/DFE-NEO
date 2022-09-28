#!/sbin/sh

read_argumetns_file(){
echo $(mygrep_prop "Skip warnin" $tmp/arguments.txt) | grep -q "true" &&
    skip_warning=true || skip_warning=false

echo $(mygrep_prop "DFE method" $tmp/arguments.txt) | grep -q "legacy" &&
    legacy_mode=true || legacy_mode=false

echo $(mygrep_prop "Flash Magisk" $tmp/arguments.txt) | grep -q "true" &&
    Flash_Magisk=true || Flash_Magisk=false

echo $(mygrep_prop "Hide No Encryption" $tmp/arguments.txt) | grep -q "true" &&
    Hide_No_Encryption=true || Hide_No_Encryption=false

echo $(mygrep_prop "Reflash Recovery for OTA" $tmp/arguments.txt) | grep -q "true" &&
    Reflash_Recovery_After_Oat=true || Reflash_Recovery_After_Oat=false

echo $(mygrep_prop "Reflash current Recovery for Recovery" $tmp/arguments.txt) | grep -q "true" &&
    Flash_Current_Rerovery=true || Flash_Current_Rerovery=false

echo $(mygrep_prop "Hide not encrypted" $tmp/arguments.txt) | grep -q "true" &&
    Hide_No_Encryption=true || Hide_No_Encryption=false

echo $(mygrep_prop "DISABLE DYNAMIC REFRESHRATE" $tmp/arguments.txt) | grep -q "true" &&
    dynamic120hz=true || dynamic120hz=false

echo $(mygrep_prop "Wipe DATA" $tmp/arguments.txt) | grep -q "true" &&
    wipe_data=true || wipe_data=false

echo $(mygrep_prop "Remove PIN" $tmp/arguments.txt) | grep -q "true" &&
    rem_lock=true || rem_lock=false

echo $(mygrep_prop "Disable QUOTA" $tmp/arguments.txt) | grep -q "true" &&
    QUOTA_STAY=true || QUOTA_STAY=false

echo $(mygrep_prop "Disable AVB" $tmp/arguments.txt) | grep -q "true" &&
    AVB_STAY=true || AVB_STAY=false

echo $(mygrep_prop "Reboot after installing" $tmp/arguments.txt) | grep -q "system" &&
    rebootARG=system && rebootafter=true

echo $(mygrep_prop "Reboot after installing" $tmp/arguments.txt) | grep -q "bootloader" &&
    rebootARG=bootloader && rebootafter=true

echo $(mygrep_prop "Reboot after installing" $tmp/arguments.txt) | grep -q "recovery" &&
    rebootARG=recovery && rebootafter=true

echo $(mygrep_prop "Safetynet fix" $tmp/arguments.txt) | grep -q "true" &&
    safetyfix=true || safetyfix=false

echo $(mygrep_prop "Force Zygisk mode" $tmp/arguments.txt) | grep -q "true" &&
    force_zygisk=true || force_zygisk=false

echo $(mygrep_prop "Add castom packages automatic in denylist" $tmp/arguments.txt) | grep -q "true" &&
    add_deny_list=true || add_deny_list=false
}