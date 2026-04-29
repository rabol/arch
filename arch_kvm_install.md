# KVM Installation on Arch Linux (Commands Only)

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
