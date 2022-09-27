#!/sbin/sh
my_print "Unpacking tools"

# Magisk unpack

unzip -o "$arg3" "arguments.txt" \
    "tools/magisklite.zip" \
    "tools/init.rc" \
    "tools/magisk.db" \
    "denylist.txt" \
    "tools/init.sh" \
    "tools/sql" \
    -j -d $tmp/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
mkdir $tmp/arm
mkdir $tmp/x86
unzip -o "$arg3" "tools/arm/keycheck" \
    -j -d $tmp/arm/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
unzip -o "$arg3" "tools/x86/keycheck" \
    -j -d $tmp/x86/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
# Magiskbin and busybox unpack
mkdir $tmp/LNG
unzip -o "$arg3" "languages/*.sh" \
    -j -d $tmp/LNG/ &>$(dirname $arg3)/log.txt || my_abort "44" "Cant unzip $arg3"
mkdir -pv $tmp/bin &>$(dirname $arg3)/log.txt
[[ -f "$tmp/magisklite.zip" ]] || my_abort "4"
unzip -o "$tmp/magisklite.zip" \
    "lib/$CPU/libmagiskboot.so" \
    "lib/$CPU/libbusybox.so" \
    "assets/bootctl" -j -d $tmp/bin/ &>$(dirname $arg3)/log.txt
cd $tmp/bin/ || my_abort "3"
for file in lib*.so; do mv "$file" "${file:3:${#file}-6}"; done
PATH=$tmp/bin:$PATH
cd $tmp || my_abort "3"
[[ -f $tmp/bin/busybox ]] || my_abort 63
chmod 777 $tmp/bin/*
BB="$tmp/bin/busybox"
chmod 777 $tmp/bin/*
cd $tmp || my_abort "3"
slot_num=$(bootctl get-current-slot)
slot_ab=$(bootctl get-suffix $slot_num)
if ! [ "$(getprop ro.virtual_ab.enabled)" = "true" ]; then
    A_only=true
fi
if $A_only; then
    sleep 0.1
elif [[ $slot_ab == "_a" ]]; then
    not_slot_ab="_b"
elif [[ $slot_ab == "_b" ]]; then
    not_slot_ab="_a"
else
    slot_ab=""
    not_slot_ab=""
    #my_abort "64" "WTF???"
fi

# Magisk unzip
TMPDIR=$tmp/magiskinst
rm -rf $TMPDIR
mkdir -p $TMPDIR
export BBBIN="$BB"
for arch in "x86_64" "x86" "arm64-v8a" "armeabi-v7a"; do
    $BB unzip -o "$tmp/magisklite.zip" "lib/$arch/libbusybox.so" -d $TMPDIR &>$(dirname $arg3)/log.txt
    libpath="$TMPDIR/lib/$arch/libbusybox.so"
    chmod 755 $libpath
    if [ -x $libpath ] && $libpath &>$(dirname $arg3)/log.txt; then
        mv -f $libpath $BBBIN
        break
    fi
done
$BBBIN rm -rf $TMPDIR/lib
export INSTALLER=$TMPDIR/install
$BBBIN mkdir -p $INSTALLER
$BBBIN unzip -o "$tmp/magisklite.zip" "assets/*" "lib/*" "META-INF/com/google/*" -x "lib/*/libbusybox.so" -d $INSTALLER &>$(dirname $arg3)/log.txt
export ASH_STANDALONE=1

umask 022
OUTFD=$2
APK="$tmp/magisklite.zip"
COMMONDIR=$INSTALLER/assets
CHROMEDIR=$INSTALLER/assets/chromeos
if [ ! -f $COMMONDIR/util_functions.sh ]; then
    my_abort "7" "! Unable to extract zip file!"
fi
mkdir $tmp/magisk_files_tmp
cp $COMMONDIR/* $tmp/magisk_files_tmp/
for file in $COMMONDIR/*.sh; do
    sed -i 's|ui_print "|echo "|' $file
done

. $COMMONDIR/util_functions.sh
get_flags &>$(dirname $arg3)/log.txt
api_level_arch_detect &>$(dirname $arg3)/log.txt
if echo $MAGISK_VER | grep -q '\.'; then
    PRETTY_VER=$MAGISK_VER
else
    PRETTY_VER="$MAGISK_VER"
fi
api_level_arch_detect &>$(dirname $arg3)/log.txt
BINDIR=$INSTALLER/lib/$ABI
cd $BINDIR || my_abort "3"
for file in lib*.so; do mv "$file" "${file:3:${#file}-6}"; done
cp -af $INSTALLER/lib/$ABI32/libmagisk32.so $BINDIR/magisk32 &>$(dirname $arg3)/log.txt
cp -af $CHROMEDIR/. $BINDIR/chromeos
chmod -R 755 $BINDIR
rm -rf $MAGISKBIN/* &>$(dirname $arg3)/log.txt
mkdir -p $MAGISKBIN &>$(dirname $arg3)/log.txt
cp -af $BINDIR/. $tmp/magisk_files_tmp/* $BBBIN $MAGISKBIN
chmod -R 755 $MAGISKBIN
cd $tmp || my_abort "3"