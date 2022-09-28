#!/sbin/sh


a7za=""
{ ./7z-arm && a7za="7z-arm" ; } || { ./7z-arm64 && a7za="7z-arm64" ; } || \
{ ./7z-7z-x86 && a7za="7z-x86" ;} || { ./7z-x86_64 && a7za="7z-x86_64" ;}