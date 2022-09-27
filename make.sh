#!/sbin/sh


arch_7z=$(uname -m)
a7za=""
arch_arm_list="aarch64_be aarch64 armv8b armv8l arm"
arch_86_list="i386 i686 x86_64"
for arch in $arch_arm_list ; do
[ $arch = $arch_7z ] && a7za="7z-arm" && break
done
[ -z $a7za ] && { 
for arch in $arch_86_list ; do
[ $arch = $arch_7z ] && a7za="7z-86" && break
done
}