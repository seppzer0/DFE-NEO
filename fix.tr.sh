#!/sbin/sh
for file in $( find ./ -name "*.sh" ) ; do
    [ -d ./tmp ] || mkdir ./tmp
    tr -d '\r' < $file > ./tmp/$(basename $file)
    rm -f $file 
    mv ./tmp/$(basename $file) $file
done