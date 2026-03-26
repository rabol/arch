# Welcome to my Arch Linux repository
This is my home for my Arch Linux journey

I tried so many distros and at the end I thought that I wanted to try Arch Linux, and with the Archinstaller, it's really not that bad / difficult to get installed.

**NOTE** Be prepared for hostile comments from other Arch Linux or Linux users in general. I for one acknowledge that it requires more effort to get Linux working compared to e.g. Windows or MacOS - I like the challenge, but trust me: at the point I ask a question I do it because I was not able to find the answer somewhere else!

I stick with KDE Plasma for the moment, as Cosmic have too many small quirks

If you have any comments start a discussion, if you have a suggestion for improvement create a PR 
# Here is what I do...

**tip** If running on a computer with WiFi only, i simply start the ```archinstall``` directly and then setup wifi before I clone.


As I'm not native English, I like to set my keyboard:

```bash 
loadkeys dk
```

I always use the latest [Arch Install](https://github.com/archlinux/archinstall)

From the Arch Linux live ISO (always get the latest ISO)

```bash
git clone https://github.com/archlinux/archinstall
```

I then get my configuration
```bash
curl -L -o user_configuration.json https://raw.githubusercontent.com/rabol/arch/main/user_configuration.json
```

**NOTE** It might contain packages that you do not like, so check before installation

```bash
cd archinstall
python -m archinstall --advanced --config ~/user_configuration.json
```

**I have tested this config many times, but on the same hardware, so in your case, check the disk / partitioning!**


# After installation

**Setup snapper**

Two packages that I always install is snapper and snap-pac

```bash
sudo snapper --config root create-config /
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

**Setup Git**

Here is my simple 5 steps:
[Setup ssh to our git](https://github.com/rabol/arch/blob/main/git_setup.md)


**Install yay**

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

I always use **pacman** before i use **yay**
