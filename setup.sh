#!/bin/bash

set -e

BASE_URL='https://rikadica.github.io/files'

function func_download_and_pack_kvm {
    wget -qO- /tmp $BASE_URL'/vkvm.tar.gz' | tar xvz -C /tmp
    wget -qO- /tmp $BASE_URL'/uefi.tar.gz' | tar xvz -C /tmp
}

function func_fownload_proxmox_iso {
    wget http://download.proxmox.com/iso/proxmox-ve_6.0-1.iso -o /mnt/proxmox.iso
}
function func_run_qemu {
    /tmp/qemu-system-x86_64 -net nic -net user,hostfwd=tcp::3389-:3389 -m 102400M -localtime \ 
    -enable-kvm -cpu host,+nx -M pc -smp 2 -vga std -usbdevice tablet -k en-us -cdrom /mnt/windows.iso -hda /dev/sda -hdb /dev/hdb -boot once=d -vnc :1
}

function func_run_qemu_uefi {
    /tmp/qemu-system-x86_64 -bios /tmp/uefi.bin -net nic -net user,hostfwd=tcp::3389-:3389 -m 102400M -localtime \ 
    -enable-kvm -cpu host,+nx -M pc -smp 2 -vga std -usbdevice tablet -k en-us -cdrom /mnt/windows.iso -hda /dev/sda -hdb /dev/hdb -boot once=d -vnc :1
}



mount -t tmpfs -o size=6000m tmpfs /mnt
func_fownload_proxmox_iso
func_download_and_pack_kvm
func_run_qemu
