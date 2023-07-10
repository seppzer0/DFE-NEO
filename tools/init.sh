#!/system/bin/sh



tmp="$1"
DFE_NEO_VER="DFE NEO 1.5.3"
mount -o rw,remount $tmp
tabul="
"
if ! [ -f $tmp/tmp_binary_neo/magisk ] ; then
mkdir $tmp/tmp_binary_neo
cp $tmp/dfe_neo_support_binary $tmp/tmp_binary_neo/magisk
fi
neo_resetprop=$tmp/tmp_binary_neo/magisk
chmod 777 $neo_resetprop
calc() { awk 'BEGIN{ print int('$1') }'; }
calcF() { awk 'BEGIN{ print '$1' }'; }
maybe_set_prop() {
        local prop="$1"
        local contains="$2"
        local value="$3"

        if [[ "$(getprop "$prop")" == *"$contains"* ]]; then
            $neo_resetprop resetprop "$prop" "$value"
            echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Reseted prop $prop on $value" >> $tmp/logdfe.txt
        else
            echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Not needed reseted $prop with $contains on $value because value $( [[ -z $(getprop "$prop") ]] && echo "empty" || echo $(getprop "$prop") )" >> $tmp/logdfe.txt
        fi
    }

DFE(){

        fstabp="$1"

        g=$(

        echo "fileencryption=" ;
        echo "forcefdeorfbe=" ;
        echo "encryptable=" ;
        echo "forceencrypt=" ;
        echo "metadata_encryption=" ;
        echo "keydirectory=" ;
        echo "avb=" ;
        echo "avb_keys=" ;

        )

        g2=$(

        echo "avb" ;
        echo "quota" ;
        echo "inlinecrypt" ;
        echo "wrappedkey" ;

        )

        while ( $( for i in $g ; do grep -q "$i" $fstabp && return 0 ; done ; return 1 ) ) ; do
            fstabp_now=$(cat "$fstabp")
            for remove in $g ; do 
                grep -q "$remove" "$fstabp" &&
                    remove_now="${fstabp_now#*"$remove"}" &&
                    remove_now="${remove_now%%,*}" &&
                    remove_now="${remove}${remove_now%%"$tabul"*}" ||
                    continue
                grep -q ",$remove_now" "$fstabp" &&
                    sed -i 's|,'$remove_now'||' $fstabp
                grep -q "$remove_now" "$fstabp" &&
                    sed -i 's|'$remove_now'||' $fstabp
                echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Remove $remove_now FLAG" >> $tmp/logdfe.txt
            done
        done        
        if ( $( for i in $g2 ; do 
                grep -q "$i" $fstabp && return 0
                done ; return 1 ) )
        then
            for remove in $g2
            do
                grep -q ",$remove" $fstabp && sed -i 's|,'$remove'||g' $fstabp
                grep -q "$remove," $fstabp && sed -i 's|'$remove',||g' $fstabp
                grep -q "$remove" $fstabp && sed -i 's|'$remove'||g' $fstabp
                echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Remove $remove FLAG" >> $tmp/logdfe.txt
            done
        fi
        #sed -i 's|/devices/platform/|#/devices/platform/|g' $fstabp
    }


case $2 in
    whiledata)
    
    until [[ "$(getprop sys.boot_completed)" == "1" ]]; do
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Check while tick" >> $tmp/logdfe.txt
        sleep 0.5
  done
    
     echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Check while fin" >> $tmp/logdfe.txt

    ;;
    whiledata2)
    
    while ! ( mount | grep -q "magisk" ) ; do
    echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- not magisk mount" >> $tmp/logdfe.txt
    done
    echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Check whilemount fin" >> $tmp/logdfe.txt

    ;;
    whiledata3)
   # {
    while ! ( ls $tmp/ | grep -q magiskpolicy ) ; do
    echo "dummy"
    done
    sleep 0.1
    PATH=$tmp/.magisk/mirror/system_root/system/bin:$PATH
    umount -f /system/bin/magisk
    umount -f /system/bin/magiskpolicy
    umount -f $tmp/.magisk/pts
    rm -f /system/bin/su /system/bin/magisk /system/bin/magiskpolicy /system/bin/supolicy
    rm -f $tmp/magisk $tmp/magisk64 $tmp/magisk32 $tmp/su $tmp/supolicy $tmp/magiskpolicy 
    mount -o ro,remount /system/bin
    sleep 0.05
    mkdir $tmp/mount_system
    mount -r $tmp/.magisk/block/system_root $tmp/mount_system
    PATH=$tmp/system_root/system/bin:$PATH
    $tmp/system_root/system/bin/mount $tmp/system_root/system /system
    
   for file in $( mount | grep magisk | grep /system/bin | awk '{print $3}' ) ; do
       umount -f $file
      ( mountpoint -q /system ) && umount -f /system
      $tmp/system_root/system/bin/mount $tmp/system_root/system /system
   done
    #mount $tmp/.magisk/mirror/system_root/system /system
    #mount -o ro,remount /system/bin
    #rm -f $tmp/magisk $tmp/magisk64 $tmp/magisk32 $tmp/magiskpolicy $tmp/supolicy
    #echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Check magisk files mirror fin" >> $tmp/logdfe.txt
   # }
    #{
    #while ! ( ls /system/bin/ | grep -q magiskpolicy ) ; do
   # echo "dummy"
   # done
 #   rm -f /system/bin/su /system/bin/magisk /system/bin/magiskpolicy /system/bin/supolicy
    #echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Check magisk files mirror fin" >> $tmp/logdfe.txt
   # }
    ;;
    
    
    add_denylist)
    
    $tmp/magisk --denylist enable
    
    for line in $( cat $tmp/denylist.txt ) ; do 
        line1=${line%\|*}
        line2=${line#*\|}
        $tmp/magisk --denylist add $line1 $line2
    done
    
    ;;
    
    
    zygisk_on)
    
    while ! [ -d /data/system ] ; do 
    sleep 0.05
    done
    chmod 777 $tmp/sql
    if [ -f /data/adb/magisk.db ] ; then
        if ( $tmp/sql /data/adb/magisk.db "SELECT * FROM settings" | grep -q zygisk ) ; then
            if ( $tmp/sql /data/adb/magisk.db "SELECT * FROM settings" | grep zygisk | grep -q 0 ) ; then
                valueDB=$( $tmp/sql /data/adb/magisk.db "SELECT rowid,* FROM settings" | grep zygisk )
                rowid=${valueDB%%\|*}
                $tmp/sql /data/adb/magisk.db "DELETE FROM settings WHERE rowid=$rowid"
                $tmp/sql /data/adb/magisk.db 'INSERT INTO settings VALUES("zygisk","1")'
            fi
        else
            $tmp/sql /data/adb/magisk.db 'INSERT INTO settings VALUES("zygisk","1")'
        fi
    else
        cp $tmp/m.db /data/adb/magisk.db
        chmod 600 /data/adb/magisk.db
    fi    
    ;;
    
    
    if_without_magisk_stop)
    if [ -f $tmp/dummy_magisk ] ; then 
    $tmp/magisk --stop
    fi
    ;;
    check_magisk_bin)
        sleep 0.1
        if ( ! [ -f "$tmp/magisk64" ] || (($(stat -c%s $tmp/magisk64) < 30)) ) && [ -f $tmp/my_mg_64 ] ; then
            cp "$tmp/my_mg_64" "$tmp/magisk64"
            chmod 777 $tmp/magisk64
            echo '#dummy' >>$tmp/dummy_magisk
        fi
        if ( ! [ -f "$tmp/magisk32" ] || (($(stat -c%s $tmp/magisk32) < 30)) ) && [ -f $tmp/my_mg_32 ] ; then
            cp "$tmp/my_mg_32" "$tmp/magisk32"
            chmod 777 $tmp/magisk64
            echo '#dummy' >>$tmp/dummy_magisk
        fi
        mkdir -pv $tmp/.magisk/zygisk
        if [ -f $tmp/magisk32 ] ; then
        cp $tmp/magisk32 $tmp/.magisk/zygisk/app_process32
        cp $tmp/magisk32 $tmp/.magisk/zygisk/magisk32
        fi
        if [ -f $tmp/magisk64 ] ; then
        cp $tmp/magisk64 $tmp/.magisk/zygisk/app_process64
        cp $tmp/magisk64 $tmp/.magisk/zygisk/magisk64
        fi
        chmod 777 $tmp/.magisk/zygisk/*
   ;;
   
   
   
   check_magisk_bin_test)
       if ! [ -f $tmp/magisk64 ] || ! [ -f $tmp/magisk32 ]; then
        if [ -f $tmp/my_mg_64 ]; then
            cp $tmp/my_mg_64 $tmp/magisk64
            chmod 777 $tmp/magisk64
        fi
        if [ -f $tmp/my_mg_32 ]; then
            cp $tmp/my_mg_32 $tmp/magisk32
            chmod 777 $tmp/magisk32
        fi
        #rm -f $tmp/su $tmp/resetprop $tmp/magisk
        #ln -sf $neo_resetprop $tmp/magisk
        #ln -sf $neo_resetprop $tmp/resetprop
        echo '#dummy' >>$tmp/dummy_magisk
    fi
;;
    casefold_remove)
        
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Starting $2" >> $tmp/logdfe.txt
    
        $neo_resetprop resetprop --delete external_storage.projid.enabled
        $neo_resetprop resetprop --delete external_storage.casefold.enabled
        $neo_resetprop resetprop --delete external_storage.sdcardfs.enabled

        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Ending $2" >> $tmp/logdfe.txt
    ;;

    patch_dfe)
    
    echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Starting $2" >> $tmp/logdfe.txt

    mkdir -pv $tmp/dfe_tmp_fstab/

    tmpF=$tmp/dfe_tmp_fstab

    for fstab in $(find /system /system_ext /odm /product /vendor -name "*fstab*"); do
        if (grep "/userdata" $fstab) &&
            (grep "/metadata" $fstab); then
            mkdir -pv $tmpF$(dirname $fstab)
            cp $fstab $tmpF$fstab
            DFE "$tmpF$fstab"
            echo '#'$DFE_NEO_VER'' >> $tmpF$fstab
            cp $tmpF$fstab $tmpF$fstab.qcom
            chmod 777 ${tmpF}${fstab}*
            mount ${tmpF}${fstab} ${fstab}
            echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Patching $fstab" >> $tmp/logdfe.txt
        fi
    done
    maybe_set_prop ro.dfe.neo.state encrypted decrypted
    echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Ending $2" >> $tmp/logdfe.txt
    
    
    ;;

    post_mount_dfe)
    
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Starting $2" >> $tmp/logdfe.txt
         
    
    
        tmpF=$tmp/dfe_tmp_fstab

        for fstab in $(find /system /system_ext /odm /product /vendor -name "*fstab*"); do
            if (grep "/userdata" $fstab) && (grep "/metadata" $fstab) && [[ -f $tmpF$fstab ]]; then
                if ! [ $(stat -c%s $fstab) = $(stat -c%s $tmpF$fstab) ] ; then 
                    chmod 777 ${tmpF}${fstab}*
                    umount $fstab
                    mount ${tmpF}${fstab}.qcom ${fstab}
                    echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Remount $fstab" >> $tmp/logdfe.txt
                fi
            fi
        done
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Ending $2" >> $tmp/logdfe.txt 

    ;;


    safetynet_init)
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Starting $2" >> $tmp/logdfe.txt
        
        $neo_resetprop resetprop ro.build.type user
        $neo_resetprop resetprop ro.debuggable 0
        $neo_resetprop resetprop ro.secure 1
        $neo_resetprop resetprop ro.boot.flash.locked 1
        $neo_resetprop resetprop ro.boot.verifiedbootstate green
        $neo_resetprop resetprop ro.boot.veritymode enforcing
        $neo_resetprop resetprop ro.boot.vbmeta.device_state locked
        $neo_resetprop resetprop vendor.boot.vbmeta.device_state locked
        $neo_resetprop resetprop ro.build.tags release-keys
        $neo_resetprop resetprop ro.boot.warranty_bit 0
        $neo_resetprop resetprop ro.vendor.boot.warranty_bit 0
        $neo_resetprop resetprop ro.vendor.warranty_bit 0
        $neo_resetprop resetprop ro.warranty_bit 0
        $neo_resetprop resetprop ro.is_ever_orange 0
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Ending $2" >> $tmp/logdfe.txt
        #chmod 777 $tmp/init.dfe.sh
        #sh $tmp/init.dfe.sh "$tmp" "whiledata" &
    ;;


    safetynet_fs)
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Starting $2" >> $tmp/logdfe.txt
        
        maybe_set_prop ro.bootmode recovery unknown
        maybe_set_prop ro.boot.mode recovery unknown
        maybe_set_prop vendor.boot.mode recovery unknown
        maybe_set_prop ro.boot.hwc CN GLOBAL
        maybe_set_prop ro.boot.hwcountry China GLOBAL
        $neo_resetprop resetprop --delete ro.build.selinux
        maybe_set_prop ro.dfe.neo.state encrypted decrypted

        if [[ "$(cat /sys/fs/selinux/enforce)" == "0" ]]; then
            chmod 640 /sys/fs/selinux/enforce
            chmod 440 /sys/fs/selinux/policy
        fi
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Ending $2" >> $tmp/logdfe.txt
    ;;


    safetynet_boot_complite)
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Starting $2" >> $tmp/logdfe.txt

        $neo_resetprop resetprop vendor.boot.verifiedbootstate green
        
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Ending $2" >> $tmp/logdfe.txt
    ;;



    patch120dynamic)
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Starting $2" >> $tmp/logdfe.txt
    
        pm $3 com.miui.powerkeeper/.statemachine.PowerStateMachineService
        
        echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Ending $2" >> $tmp/logdfe.txt
    ;;
esac
