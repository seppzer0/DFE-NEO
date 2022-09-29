#!/sbin/sh
# Magisk unzip

export BBBIN="$BB"
# unzip chromeos and others
export INSTALLER="$tmp/my_bins"
$BB unzip -o "$tmp/others.magisk.files.zip" -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
$BB unzip -o "$tmp/$magisk_ver_install.zip" "assets/*" -d $INSTALLER &>"$my_log" || my_abort "44" "Cant unzip $arg3"
$BB mv $INSTALLER/assets/* $INSTALLER/
# $INSTALLER/magiskboot{arch}:busybox{arch}:bootctl{all}:all files in assets folder

export ASH_STANDALONE=1

$BB unzip -o "$tmp/$magisk_ver_install.zip" "lib/$big_arch/*" -j -d $INSTALLER/ &>"$my_log" || my_abort "44" "Cant unzip $arg3"
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