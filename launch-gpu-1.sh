#!/bin/bash

configfile=gpu-1.cfg

vfiobind() {
    dev="$1"
        vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
        device=$(cat /sys/bus/pci/devices/$dev/device)
        if [ -e /sys/bus/pci/devices/$dev/driver ]; then
                echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
        fi
        echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/new_id

}

modprobe vfio-pci

cat $configfile | while read line;do
    echo $line | grep ^# >/dev/null 2>&1 && continue
        vfiobind $line
done

sudo qemu-system-x86_64 -enable-kvm -M q35 -m 8192 -cpu host \
-smp 4,sockets=1,cores=4,threads=1 \
-bios /usr/share/qemu/bios.bin -vga none \
-device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
-device vfio-pci,host=83:00.0,bus=root.1,addr=00.0,multifunction=on,x-vga=on \
-device vfio-pci,host=83:00.1,bus=root.1,addr=00.1 \
-device vfio-pci,host=84:00.0,bus=pcie.0 \
-device vfio-pci,host=02:00.1,bus=root.1,addr=00.1 \
-drive file=/media/windows/gpu-1.img,id=disk,format=raw -device ide-hd,bus=ide.0,drive=disk \
-drive file=/home/elerek/images/en_windows_enterprise_10.iso,id=isocd -device ide-cd,bus=ide.1,drive=isocd \
-boot menu=on

exit 0

