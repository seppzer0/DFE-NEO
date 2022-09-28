#!/sbin/sh

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
{ "$tmp"/my_BB/busybox-x86_64 && BB="$tmp/my_BB/busybox-x86_64" && MB="$tmp/magiskboot/magiskboot-x86_64"; } ||
    { "$tmp"/my_BB/busybox-x86 && BB="$tmp/my_BB/busybox-x86" && MB="$tmp/magiskboot/magiskboot-x86"; } ||
    { "$tmp"/my_BB/busybox-arm64 && BB="$tmp/my_BB/busybox-arm64" && MB="$tmp/magiskboot/magiskboot-arm64"; } ||
    { "$tmp"/my_BB/busybox-arm && BB="$tmp/my_BB/busybox-arm" && MB="$tmp/magiskboot/magiskboot-arm"; } ||
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
if ! [ "$(getprop ro.virtual_ab.enabled)" = "true" ]; then A_only=true ; fi
if $A_only; then sleep 0.1
elif [[ $slot_ab == "_a" ]]; then not_slot_ab="_b"
elif [[ $slot_ab == "_b" ]]; then not_slot_ab="_a"
else slot_ab="" ; not_slot_ab=""
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
