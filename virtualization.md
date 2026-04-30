# KVM Installation on Arch Linux (Complete & Corrected)

This guide is based on [How Do I Properly Install KVM on Linux](https://sysguides.com/install-kvm-on-linux)

Check the video on [Youtube](https://www.youtube.com/watch?v=LHJhFW7_8EI)

## 1. Check Virtualization Support
```bash
lscpu | grep Virtualization
```

## 2. Check Kernel KVM Support
```bash
zgrep CONFIG_KVM /proc/config.gz
```

## 3. Install Required Packages
```bash
sudo pacman -S qemu-full libvirt virt-install virt-manager virt-viewer     edk2-ovmf swtpm qemu-img guestfs-tools libosinfo
```

## 4. (Optional) Install tuned (AUR)
```bash
yay -S tuned
```

## 5. Enable libvirt services (modern modular setup)
```bash
for drv in qemu interface network nodedev nwfilter secret storage; do     sudo systemctl enable virt${drv}d.service;     sudo systemctl enable virt${drv}d{,-ro,-admin}.socket;   done
```

## 6. Enable legacy libvirtd (compatibility)
```bash
sudo systemctl enable libvirtd.service
```

## 7. Add user to libvirt group
```bash
sudo usermod -aG libvirt $USER
```

## 8. Set default libvirt URI
```bash
echo "export LIBVIRT_DEFAULT_URI='qemu:///system'" >> ~/.bashrc
```

## 9. Apply environment changes
```bash
source ~/.bashrc
```

## 10. Fix storage permissions

Note: do not ues$USER as that will resolve to root when using sudo

```bash
sudo setfacl -R -b /var/lib/libvirt/images
sudo setfacl -R -m u:<your_user>:rwX /var/lib/libvirt/images
sudo setfacl -m d:u:<your_user>:rwx /var/lib/libvirt/images
```

## 11. Reboot
```bash
sudo reboot
```

## 12. Validate Installation
```bash
sudo virt-host-validate qemu
```

## 13. (Optional) Enable tuned
```bash
sudo systemctl enable --now tuned
```

## 14. (Optional) Set tuned Profile
```bash
sudo tuned-adm profile virtual-host
```

## 15. (Optional) Verify tuned
```bash
sudo tuned-adm verify
```

---

# Network Bridge Configuration

## 1. Install (if not already installed) and enable NetworkManager
```bash
sudo pacman -S networkmanager
sudo systemctl enable --now NetworkManager
```

## 2. Check current network devices
```bash
sudo nmcli device status
```

## 3. Create bridge interface
```bash
sudo nmcli connection add type bridge con-name bridge0 ifname bridge0
```

## 4. Add your physical interface to the bridge
```bash
sudo nmcli connection add type ethernet slave-type bridge con-name 'Bridge connection 1' ifname enp2s0 master bridge0
```

## 5. Assign IP address
```bash
sudo nmcli connection modify bridge0 ipv4.addresses '192.168.1.7/24'
```

## 6. Set gateway
```bash
sudo nmcli connection modify bridge0 ipv4.gateway '192.168.1.1'
```

## 7. Set DNS
```bash
sudo nmcli connection modify bridge0 ipv4.dns '8.8.8.8,8.8.4.4'
```

## 8. Set DNS search domain -  optional
```bash
sudo nmcli connection modify bridge0 ipv4.dns-search 'sysguides.com'
```

## 9. Set manual IP method
```bash
sudo nmcli connection modify bridge0 ipv4.method manual
```

## 10. Bring up bridge
```bash
sudo nmcli connection up bridge0
```

## 11. Enable autoconnect for slaves
```bash
sudo nmcli connection modify bridge0 connection.autoconnect-slaves 1
```

## 12. Bring up again
```bash
sudo nmcli connection up bridge0
```

## 13. Verify
```bash
sudo nmcli device status
```

```bash
ip -brief addr show dev bridge0
```

---

## Create libvirt bridge network

```bash
vim nwbridge.xml
```

```xml
<network>
  <name>nwbridge</name>
  <forward mode='bridge'/>
  <bridge name='bridge0'/>
</network>
```

```bash
sudo virsh net-define nwbridge.xml
```

```bash
sudo virsh net-start nwbridge
```

```bash
sudo virsh net-autostart nwbridge
```

## Verify networks
```bash
sudo virsh net-list --all
```
