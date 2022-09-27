#!/bin/sh
MYSELECT4() {
    my_print "> [$1]" "selected"
    my_print "> [$2]" "selected"
    my_print "> [$3]" "selected"
    my_print "> [$4]" "selected"
    my_print "> [$text4] " "selected"
    ui_print " "
    A=1
    while true; do
        case $A in
        1)
            TEXT="$1"
            outselect=1
            ;;
        2)
            TEXT="$2"
            outselect=2
            ;;
        3)
            TEXT="$3"
            outselect=3
            ;;
        4)
            TEXT="$4"
            outselect=4
            ;;
        5)
            TEXT="$text4"
            outselect=5
            ;;
        esac

        my_print " > $TEXT <" "selected"
        if chooseport 60; then
            A=$((A + 1))
        else
            break
        fi
        if [ $A -gt 5 ]; then
            A=1
        fi
    done
    if [ $outselect = 5 ]; then
        my_abort "1"
    fi

    my_print " >[$TEXT]<" "selected"
    ui_print " "
    ui_print "****==================================*****"
    return $outselect
}

MYSELECT() {
    my_print "> [$1]" "selected"
    ! [ -z "$3" ] && my_print "$3"
    my_print "> [$2]" "selected"
    ! [ -z "$4" ] && my_print "$4"
    my_print "> [$text4]" "selected"
    ui_print " "
    A=1
    while true; do
        case $A in
        1)
            TEXT="$1"
            outselect=1
            ;;
        2)
            TEXT="$2"
            outselect=2
            ;;
        3)
            TEXT="$text4"
            outselect=3
            ;;
            #4 ) TEXT="EXIT" ; outselect=4 ;;
        esac

        my_print " > $TEXT <" "selected"
        if chooseport 60; then
            A=$((A + 1))
        else
            break
        fi
        if [ $A -gt 3 ]; then
            A=1
        fi
    done
    if [ $outselect = 3 ]; then
        my_abort "1"
    fi

    my_print " >[$TEXT]<" "selected"
    ui_print " "
    ui_print "****==================================*****"
    return $outselect
}