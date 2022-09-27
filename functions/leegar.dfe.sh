#!/sbin/sh
tabul="
"
DFE() {
    fstabp=$1
    g=$(
        echo "fileencryption="
        echo "forcefdeorfbe="
        echo "encryptable="
        echo "forceencrypt="
        echo "metadata_encryption="
        echo "keydirectory="
        $AVB_STAY && echo "avb="
        $AVB_STAY && echo "avb_keys="
    )
    g2=$(
        $AVB_STAY && echo "avb"
        $QUOTA_STAY && echo "quota"
        echo "inlinecrypt"
        echo "wrappedkey"
    )
    while ($(
        for i in $g; do grep -q "$i" $fstabp && return 0
        done
        return 1
    )); do
        fstabp_now=$(cat "$fstabp")
        for remove in $g; do
            grep -q "$remove" "$fstabp" &&
                remove_now="${fstabp_now#*"$remove"}" &&
                remove_now="${remove_now%%,*}" &&
                remove_now="${remove}${remove_now%%"$tabul"*}" ||
                continue
            grep -q ",$remove_now" "$fstabp" &&
                sed -i 's|,'$remove_now'||' $fstabp
            grep -q "$remove_now" "$fstabp" &&
                sed -i 's|'$remove_now'||' $fstabp
        done
    done
    if ($(
        for i in $g2; do
            grep -q "$i" $fstabp && return 0
        done
        return 1
    )); then
        for remove in $g2; do
            grep -q ",$remove" $fstabp && sed -i 's|,'$remove'||g' $fstabp
            grep -q "$remove," $fstabp && sed -i 's|'$remove',||g' $fstabp
            grep -q "$remove" $fstabp && sed -i 's|'$remove'||g' $fstabp
        done
    fi
}
DFE_INIT() {
    fstabp="$1"
    g=$(
        echo "fileencryption="
        echo "forcefdeorfbe="
        echo "encryptable="
        echo "forceencrypt="
        echo "metadata_encryption="
        echo "keydirectory="
        echo "avb="
        echo "avb_keys="
    )
    g2=$(
        echo "avb"
        echo "quota"
        echo "inlinecrypt"
        echo "wrappedkey"
    )
    while ($(
        for i in $g; do grep -q "$i" $fstabp && return 0; done
        return 1
    )); do
        fstabp_now=$(cat "$fstabp")
        for remove in $g; do
            grep -q "$remove" "$fstabp" &&
                remove_now="${fstabp_now#*"$remove"}" &&
                remove_now="${remove_now%%,*}" &&
                remove_now="${remove}${remove_now%%"$tabul"*}" ||
                continue
            grep -q ",$remove_now" "$fstabp" &&
                sed -i 's|,'$remove_now'||' $fstabp
            grep -q "$remove_now" "$fstabp" &&
                sed -i 's|'$remove_now'||' $fstabp
            echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Remove $remove_now FLAG" >>$tmp/logdfe.txt
        done
    done
    if ($(
        for i in $g2; do
            grep -q "$i" $fstabp && return 0
        done
        return 1
    )); then
        for remove in $g2; do
            grep -q ",$remove" $fstabp && sed -i 's|,'$remove'||g' $fstabp
            grep -q "$remove," $fstabp && sed -i 's|'$remove',||g' $fstabp
            grep -q "$remove" $fstabp && sed -i 's|'$remove'||g' $fstabp
            echo "$DFE_NEO_VER : $(date +%G:%m:%d:%H:%M:%S:%N) -- Remove $remove FLAG" >>$tmp/logdfe.txt
        done
    fi
}