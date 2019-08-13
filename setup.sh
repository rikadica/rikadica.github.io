#!/bin/bash

set -e

BASE_URL='https://rikadica.github.io/files'

function func_download_and_unpack_kvm {
    wget -qO- /tmp $BASE_URL'/vkvm.tar.gz' | tar xvz -C /tmp
    wget -qO- /tmp $BASE_URL'/uefi.tar.gz' | tar xvz -C /tmp
}

function func_download_proxmox_iso {
    wget http://download.proxmox.com/iso/proxmox-ve_6.0-1.iso -O /mnt/proxmox.iso
}
function func_run_qemu {
    /tmp/qemu-system-x86_64 -net nic -net user,hostfwd=tcp::3389-:3389 -m 102400M -localtime -enable-kvm -cpu host,+nx -M pc -smp 2 -vga std -usbdevice tablet -k en-us -cdrom /mnt/proxmox.iso -hda /dev/sda -hdb /dev/sdb -boot once=d -vnc :1
}

function func_run_qemu_uefi {
    /tmp/qemu-system-x86_64 -bios /tmp/uefi.bin -net nic -net user,hostfwd=tcp::3389-:3389 -m 102400M -localtime -enable-kvm -cpu host,+nx -M pc -smp 2 -vga std -usbdevice tablet -k en-us -cdrom /mnt/proxmox.iso -hda /dev/sda -hdb /dev/sdb -boot once=d -vnc :1
}

function func_erase_disks {
    ATTRS=($(lsblk -d -n -l | grep -P " disk" | grep -E -o "(^sd[a-z]) "))
    #echo $ATTRS
    for i in "${ATTRS[@]}"
    do
    :
    ii='/dev/'$i
    #echo $ii
    #exit
    #sfdisk $i < ""
    #dd if=/dev/zero of=$ii bs=512 count=1
    blkdiscard -v $ii || echo "not supported"
    #echo $ii "cleaned"
    done
    #echo $ATTRS
}


func_prompt_confirm() {
  lsblk -d | grep "^sd"
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac
  done
}


func_prompt_confirm "This command will erase all your data on your disks. Are you shure?" || exit 0
func_erase_disks
mount -t tmpfs -o size=6000m tmpfs /mnt
func_download_proxmox_iso
func_download_and_unpack_kvm
func_run_qemu
