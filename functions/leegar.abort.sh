#!/sbin/sh
my_abort() {
    error_code="$1"
    error_text="$2"

    if ! [ -z "$error_text" ]; then
        ui_print "*******************************"
        ui_print "*******************************"
        ui_print " "
        my_print "$2"
        ui_print " "
        ui_print "*******************************"
        ui_print "*******************************"
    fi
    my_print "$text1 $error_code"
    exit $error_code
}