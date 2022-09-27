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
        
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_64" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_64"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/my_mg_32" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/my_mg_32"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/init.dfe.sh" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/init.dfe.sh"
        magiskboot cpio ramdisk.cpio "exists overlay.d/init.dfe.rc" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/init.dfe.rc"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/dfe_neo_support_binary" && \
        magiskboot cpio ramdisk.cpio "rm overlay.d/sbin/dfe_neo_support_binary"
        magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/dfe.neo.magisk.lib.txt" && \
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
                magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" && \
                echo magisk64 >> dfe.neo.magisk.lib.txt
                magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" && \
                echo magisk32 >> dfe.neo.magisk.lib.txt
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
                if ( magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk64.xz" ) ; then
                magiskboot cpio ramdisk.cpio "extract overlay.d/sbin/magisk64.xz 64.xz"
                magiskboot decompress 64.xz my_mg_64
                echo magisk64 >> dfe.neo.magisk.lib.txt
                magiskboot cpio ramdisk.cpio "add 0750 overlay.d/sbin/my_mg_64 my_mg_64"
                fi
                if ( magiskboot cpio ramdisk.cpio "exists overlay.d/sbin/magisk32.xz" ) ; then
                magiskboot cpio ramdisk.cpio "extract overlay.d/sbin/magisk32.xz 32.xz"
                magiskboot decompress 32.xz my_mg_32
                echo magisk32 >> dfe.neo.magisk.lib.txt
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