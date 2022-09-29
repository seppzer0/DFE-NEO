#!/sbin/sh
$force_zygisk || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} zygisk_on||g' "$tmp"/init.add.rc
}

$add_deny_list || {
    sed -i 's|exec_background u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} add_denylist||g' "$tmp"/init.add.rc
}
$Hide_No_Encryption || {
    sed -i 's|setprop ro.crypto.state encrypted||' "$tmp"/init.add.rc
}
$QUOTA_STAY || {
    sed -i 's|echo "quota"|#echo "quota"|' "$tmp"/init.sh
}
$safetyfix || {
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_fs||g' "$tmp"/init.add.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_init||g' "$tmp"/init.add.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} safetynet_boot_complite||g' "$tmp"/init.add.rc
}
$AVB_STAY || {
    sed -i 's|echo "avb="|#echo "avb="|' "$tmp"/init.sh &&
        sed -i 's|echo "avb_keys="|#echo "avb_keys="|' "$tmp"/init.sh &&
        sed -i 's|echo "avb"|#echo "avb"|' "$tmp"/init.sh
}
$dynamic120hz || {
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic enable||g' "$tmp"/init.add.rc
    sed -i 's|exec u:r:magisk:s0 root root --  ${MAGISKTMP}/init.dfe.sh ${MAGISKTMP} patch120dynamic disable||g' "$tmp"/init.add.rc
}

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
        [[ -z $boot ]] && my_abort 4
        cd $tmp_boot
        $MB unpack -h $boot &>$(dirname $arg3)/log.txt
        $MB cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_64" && $MB cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_64"
        $MB cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_32" && $MB cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_32"
        $MB cpio ramdisk.cpio "exists overlay.d/sbin/init.dfe.sh" && $MB cpio ramdisk.cpio "rm overlay.d/sbin/init.dfe.sh"
        $MB cpio ramdisk.cpio "exists overlay.d/init.dfe.rc" && $MB cpio ramdisk.cpio "rm overlay.d/init.dfe.rc"
        $MB cpio ramdisk.cpio "exists overlay.d/init.add.rc" && $MB cpio ramdisk.cpio "rm overlay.d/init.add.rc"
        $MB cpio ramdisk.cpio "exists overlay.d/sbin/dfe_neo_support_binary" && $MB cpio ramdisk.cpio "rm overlay.d/sbin/dfe_neo_support_binary"

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
                cd $tmp || my_abort "3"
            else
                my_abort "65" "$text76"
            fi
        fi

        if $Reflash_Recovery_After_Oat && $my_magisk_installer && ! [ $forslot = "A_only" ]; then
            if [[ $forslot == $not_slot_ab ]]; then
                mkdir -pv $tmp/recovery$slot_ab &>$(dirname $arg3)/log.txt
                cd $tmp/recovery$slot_ab || my_abort "3"
                $MB unpack -h /dev/block/by-name/boot$slot_ab &>$(dirname $arg3)/log.txt
                rm -f $tmp_boot/ramdisk.cpio
                mv $tmp/recovery$slot_ab/ramdisk.cpio $tmp_boot/ramdisk.cpio
                cd $tmp || my_abort "3"
            fi
        fi

        if $Flash_Magisk; then

            cp $BINDIR/* $tmp_boot/
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
            1) abort "! Insufficient partition size" ;;
            2) abort "! $BOOTIMAGE is read only" ;;
            esac
            run_migrations &>$(dirname $arg3)/log.txt
            cd $tmp || my_abort "3"
        fi

        if $Flash_DFE && ! $legacy_mode; then
            my_print "$text79 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
            cd $tmp_boot || my_abort "3"
            $MB cpio ramdisk.cpio test &>$(dirname $arg3)/log.txt
            STATUSM=$?
            if [ "$STATUSM" = "0" ] ||
                ( ! ($MB cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" &>$(dirname $arg3)/log.txt) ||
                    ! ($MB cpio ramdisk.cpio "exists overlay.d/sbin/magisk32.xz" &>$(dirname $arg3)/log.txt)); then
                STATUSM=0
            fi
            case $STATUSM in
            1)
                my_print "$text80 $($A_only || echo $text78 $forslot)"
                my_print "$text81 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
                ;;
            0)
                my_print "$text82 $($A_only || echo $text78 $forslot)"
                my_print "$text83 $($A_only || echo $text78 $forslot)"
                cp $BINDIR/* $tmp_boot/
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
                1) abort "! Insufficient partition size" ;;
                2) abort "! $BOOTIMAGE is read only" ;;
                esac
                run_migrations &>$(dirname $arg3)/log.txt
                cd $tmp_boot || my_abort "3"
                my_print "$text85 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
                if ($MB cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz"); then
                    $MB cpio ramdisk.cpio "extract overlay.d/sbin/magisk64.xz 64.xz"
                    $MB decompress 64.xz my_mg_64
                    $MB cpio ramdisk.cpio "add 0750 overlay.d/sbin/my_mg_64 my_mg_64"
                fi
                if ($MB cpio ramdisk.cpio "exists overlay.d/sbin/magisk32.xz"); then
                    $MB cpio ramdisk.cpio "extract overlay.d/sbin/magisk32.xz 32.xz"
                    $MB decompress 32.xz my_mg_32
                    $MB cpio ramdisk.cpio "add 0750 overlay.d/sbin/my_mg_32 my_mg_32"
                fi
                $MB cpio ramdisk.cpio \
                    "rm overlay.d/sbin/magisk64.xz" \
                    "rm overlay.d/sbin/magisk32.xz" &>$(dirname $arg3)/log.txt

                ;;
            esac
            cd $tmp_boot
            $MB cpio ramdisk.cpio "add 0750 overlay.d/init.dfe.rc $tmp/init.dfe.rc"
        fi

        $BB unzip -o "$tmp/$magisk_ver_install.zip" \
            "lib/$CPU/libmagisk64.so" -j -d $tmp_boot &>$(dirname $arg3)/log.txt
        $BB unzip -o "$tmp/$magisk_ver_install.zip" \
            "lib/$CPU/libmagisk32.so" -j -d $tmp_boot &>$(dirname $arg3)/log.txt
        [ -f $tmp_boot/libmagisk64.so ] && inject_my_magisk=$tmp_boot/libmagisk64.so
        [ -f $tmp_boot/libmagisk32.so ] && inject_my_magisk=$tmp_boot/libmagisk32.so
        $MB cpio ramdisk.cpio "exists .backup/.magisk" &>$(dirname $arg3)/log.txt && {
            $MB cpio ramdisk.cpio "extract .backup/.magisk fconfig" &>$(dirname $arg3)/log.txt
        }
        (grep -q "KEEPVERITY=true" fconfig) && sed -i 's|KEEPVERITY=true|KEEPVERITY=false|' fconfig
        (grep -q "KEEPFORCEENCRYPT=true" fconfig) && sed -i 's|KEEPFORCEENCRYPT=true|KEEPFORCEENCRYPT=false|' fconfig
        $MB cpio ramdisk.cpio \
            "add 0750 overlay.d/sbin/init.dfe.sh $tmp/init.sh" \
            "add 0750 overlay.d/sbin/m.db $tmp/magisk.db" \
            "add 0750 overlay.d/sbin/sql $tmp/sql" \
            "add 0750 overlay.d/init.add.rc $tmp/init.add.rc" \
            "add 0750 overlay.d/sbin/denylist.txt $tmp/denylist.txt" \
            "add 0750 overlay.d/sbin/dfe_neo_support_binary $inject_my_magisk" \
            "add 000 .backup/.magisk fconfig" &>$(dirname $arg3)/log.txt
        cd $tmp_boot
        my_print "$text113 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
        $MB repack $boot &>$(dirname $arg3)/log.txt
        my_print "$text114 ($(basename $boot)) $($A_only || echo $text78 $forslot)"
        flash_image ./new-boot.img $boot
        #cp ./new-boot.img /sdcard/boot$forslot.img
        cd $tmp
        rm -rf $tmp_boot
    } &
done
wait
