#!/sbin/sh
rw_part_check() {
    mnt="$1"
    echo "test test test TEST TESTR TEST" &>$mnt/test.txt
    if [[ $(stat -c%s $mnt/test.txt) -ge 6 ]]; then
        rm -f $mnt/test.txt
        return 0
    else
        [[ -f $mnt/test.txt ]] && rm -f $mnt/test.txt
        return 1
    fi
}

mount_part() {
    for mnt in vendor $($my_magisk_installer && echo system || echo system_root) odm system_ext product; do
        case "$1" in
        --mount)
            if ! $my_magisk_installer; then
                umount /$mnt
                e2fsck -f /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                blockdev --setrw /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                e2fsck -E unshare_blocks -y -f /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                resize2fs /dev/block/mapper/$([[ $mnt == system_root ]] && echo system || echo $mnt)$slot_ab
                mount /$mnt
            fi
            mount -o rw,remount /$mnt
            $my_magisk_installer && mount -o rw,remount /
            ;;
        --umount)
            (mountpoint -q /$mnt) && umount /$mnt
            ;;
        esac
    done
}
