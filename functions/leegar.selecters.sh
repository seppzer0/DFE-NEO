#!/sbin/sh
MYSELECT() {
    ui_print ""
    text_for_select=""
    text_select=""
    text_input=""
    text_commend=""
    
    [ -z "$1" ] || my_print "$1"
    ui_print ""
    tick_for=1
    for text in "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}" "${13}" "${14}" "${15}"; do
        [ -z "$text" ] && break
        text_input=${text%:comment:*}
        text_select=${text_input#*:select:}
        text_input=${text_input%:select:*}
        text_commend=${text#*:comment:}

        my_print "${tick_for}) [$text_input]" "selected"
        (echo $text | grep -q ':comment:') && my_print "--${text_commend}--" "selected"
        [ -z "$text_for_select" ] &&
            text_for_select="${tick_for}) $text_select" ||
            text_for_select="${text_for_select}\n${tick_for}) ${text_select}"
        tick_for=$((tick_for + 1))
    done

    text_for_select="${text_for_select}\n${text4}"

    tick_select=1
    all_ticks=$(echo -e $text_for_select | wc -l)
    while true; do
        my_print " > $(echo -e $text_for_select | head -n$tick_select | tail -n1) <" "selected"
        if chooseport 60; then
            tick_select=$((tick_select + 1))
        else
            break
        fi
        if [ $tick_select -gt $all_ticks ]; then
            tick_select=1
        fi
    done
    my_print " >[$(echo -e $text_for_select | head -n$tick_select | tail -n1)]<" "selected"
    ui_print " "
    ui_print "**==================================***"
    if [ "$(echo -e $text_for_select | head -n$tick_select | tail -n1)" = "${text4}" ]; then
        my_abort "1"
    fi
    if [ $all_ticks -le 3 ]; then
        [ $tick_select = 1 ] && return 0
        [ $tick_select = 2 ] && return 1
    else
        return $tick_select
    fi
}

