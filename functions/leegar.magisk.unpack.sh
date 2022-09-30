#!/sbin/sh
# Magisk unzip
magisk_unpack() {
    export BBBIN="$BB"
    export INSTALLER="$tmp/my_bins"
    export ASH_STANDALONE=1
    OUTFD=$arg2
    APK="$tmp/$magisk_ver_install.zip"
    COMMONDIR=$INSTALLER
    BINDIR=$INSTALLER
    CHROMEDIR=$INSTALLER/chromeos

    case $1 in
    unpack)
        # unzip chromeos and others

        $BB unzip -o "$tmp/others.magisk.files.zip" -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
        $BB unzip -o "$tmp/$magisk_ver_install.zip" "assets/*" -d $INSTALLER &>"$my_log" || my_abort "44" "Cant unzip $arg3"
        $BB mv $INSTALLER/assets/* $INSTALLER/
        # $INSTALLER/magiskboot{arch}:busybox{arch}:bootctl{all}:all files in assets folder
        [ -z "$2" ] || {
            case $2 in
            x86_64) little_arch="x86" && big_arch="x86_64" ;;
            x86) little_arch="x86" && big_arch="x86" ;;
            arm64-v8a) little_arch="armeabi-v7a" && big_arch="arm64-v8a" ;;
            armeabi-v7a) little_arch="armeabi-v7a" && big_arch="armeabi-v7a" ;;
            esac
        }
        $BB unzip -o "$tmp/$magisk_ver_install.zip" "lib/$big_arch/*" -j -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
        if ! [ $little_arch = $big_arch ]; then
            $BB unzip -o "$tmp/$magisk_ver_install.zip" "lib/$little_arch/libmagisk32.so" -j -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
        fi
        for file in $INSTALLER/lib*.so; do
            $BB mv $file $(dirname $file)/$(basename $file | sed 's|lib||' | sed 's|.so||')
        done
        # $INSTALLER/magiskboot{arch}:busybox{arch}:bootctl{all}:magisk32/64:magiskinit:magiskpolicy:all files in assets folder

        umask 022

        [ -f $COMMONDIR/util_functions.sh ] || my_abort "7" "! Unable to extract zip file!"

        # Backup magisk scripts
        mkdir -pv $tmp/magisk_files_tmp &>"$my_log"
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
        ;;
    migrate)
        chmod -R 755 $BINDIR
        rm -rf $MAGISKBIN/* &>"$my_log"
        mkdir -p $MAGISKBIN &>"$my_log"
        cp -af $BINDIR/* $MAGISKBIN/
        chmod -R 755 $MAGISKBIN
        ;;
    esac
}
