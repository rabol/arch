# KVM Installation on Arch Linux (Complete)

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

## 4. Install tuned (AUR)
```bash
yay -S tuned
```

## 5. Enable libvirt
```bash
sudo systemctl enable libvirtd.service
```

## 6. Reboot
```bash
sudo reboot
```

## 7. Validate Installation
```bash
sudo virt-host-validate qemu
```

### enable user
```bash
sudo usermod -aG libvirt $USER
```

## 8. Enable tuned
```bash
sudo systemctl enable --now tuned
```

## 9. Set tuned Profile
```bash
sudo tuned-adm profile virtual-host
```

## 10. Verify tuned
```bash
sudo tuned-adm verify
```

---

# Network Bridge Configuration

## 1. Check current network devices
```bash
sudo nmcli device status
```

## 2. Create bridge interface
```bash
sudo nmcli connection add type bridge con-name bridge0 ifname bridge0
```

## 3. Add your physical interface to the bridge
```bash
sudo nmcli connection add type ethernet slave-type bridge     con-name 'Bridge connection 1' ifname enp2s0 master bridge0
```

## 4. Assign IP address
```bash
sudo nmcli connection modify bridge0 ipv4.addresses '192.168.1.7/24'
```

## 5. Set gateway
```bash
sudo nmcli connection modify bridge0 ipv4.gateway '192.168.1.1'
```

## 6. Set DNS
```bash
sudo nmcli connection modify bridge0 ipv4.dns '8.8.8.8,8.8.4.4'
```

## 7. Set DNS search domain
```bash
sudo nmcli connection modify bridge0 ipv4.dns-search 'rabol.dev'
```

## 8. Set manual IP method
```bash
sudo nmcli connection modify bridge0 ipv4.method manual
```

## 9. Bring up bridge
```bash
sudo nmcli connection up bridge0
```

## 10. Enable autoconnect for slaves
```bash
sudo nmcli connection modify bridge0 connection.autoconnect-slaves 1
```

## 11. Bring up again
```bash
sudo nmcli connection up bridge0
```

## 12. Verify
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
