
folder_dir=$(dirname $0)
chmod 777 $folder_dir/7za/*
a7za=""
{ $folder_dir/7za/7z-arm &> /dev/null && a7za="7z-arm" ; } || { $folder_dir/7za/7z-arm64 &> /dev/null && a7za="7z-arm64" ; } || \
{ $folder_dir/7za/7z-7z-x86 &> /dev/null && a7za="7z-x86" ;} || { $folder_dir/7za/7z-x86_64 &> /dev/null && a7za="7z-x86_64" ;}

a7za=$folder_dir/7za/$a7za

for file in $( find $folder_dir/ -name "*.sh" ) ; do
    [ -d $folder_dir/tmp ] || mkdir $folder_dir/tmp
    tr -d '\r' < $file > $folder_dir/tmp/$(basename $file)
    rm -f $file 
    mv $folder_dir/tmp/$(basename $file) $file
done
rm -rf $folder_dir/tmp

rm -rf $folder_dir/zip_structure
mkdir -pv $folder_dir/zip_structure/META-INF/com/google/android
mkdir -pv $folder_dir/zip_structure/languages
mkdir -pv $folder_dir/zip_structure/tools/magisk

cat $folder_dir/scripts/first.startup.sh >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/leegar.print.sh | sed 's|#!/sbin/sh|#leegar.print|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/chainfire.ianmacd.chooseport.sh | sed 's|#!/sbin/sh|#chainfire.ianmacd.chooseport|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/leegar.abort.sh | sed 's|#!/sbin/sh|#leegar.abort|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/leegar.grep.calc.sh | sed 's|#!/sbin/sh|#leegar.grep.calc|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/leegar.read.arguments.sh | sed 's|#!/sbin/sh|#leegar.read.arguments|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/leegar.selecters.sh | sed 's|#!/sbin/sh|#leegar.selecters|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/leegar.dfe.sh | sed 's|#!/sbin/sh|#leegar.dfe|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/functions/leegar.mount.sh | sed 's|#!/sbin/sh|#leegar.mount|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/scripts/unpacking.tool.sh | sed 's|#!/sbin/sh|#unpacking.tool|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/scripts/argumetns.startup.sh | sed 's|#!/sbin/sh|#argumetns.startup|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/scripts/unpacking.magisk.sh | sed 's|#!/sbin/sh|#unpacking.magisk|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/scripts/patching.boot.sh | sed 's|#!/sbin/sh|#patching.boot|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh
cat $folder_dir/scripts/ending.sh | sed 's|#!/sbin/sh|#ending|' >> $folder_dir/zip_structure/customize.sh
echo " " >> $folder_dir/zip_structure/customize.sh


for magisk in $folder_dir/magisk/* ; do
$a7za a -r -mmt8 -mx9 $folder_dir/zip_structure/tools/magisk/$( basename $magisk ).zip $folder_dir/magisk/$( basename $magisk )/* -bso0
done
$a7za a -r -mmt8 -mx9 $folder_dir/zip_structure/tools/busybox.zip $folder_dir/busybox/* -bso0
$a7za a -r -mmt8 -mx9 $folder_dir/zip_structure/tools/magiskboot.zip $folder_dir/magiskboot/* -bso0
$a7za a -r -mmt8 -mx9 $folder_dir/zip_structure/tools/others.magisk.files.zip $folder_dir/others.magisk.files/* -bso0

echo '#MAGISK' >> $folder_dir/zip_structure/META-INF/com/google/android/updater-script
cat $folder_dir/scripts/basic.start.sh >> $folder_dir/zip_structure/META-INF/com/google/android/update-binary

cat $folder_dir/scripts/init.add.rc >> $folder_dir/zip_structure/tools/init.add.rc
cat $folder_dir/scripts/init.dfe.rc >> $folder_dir/zip_structure/tools/init.dfe.rc
cat $folder_dir/scripts/init.sh >> $folder_dir/zip_structure/tools/init.sh
cp $folder_dir/tools/* $folder_dir/zip_structure/tools/
cp $folder_dir/languages/* $folder_dir/zip_structure/languages/
cp $folder_dir/stuff/* $folder_dir/zip_structure/

