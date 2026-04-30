## Spice up your nano

```bash
mkdir -p ~/.config/nano
```

```bash
nano ~/.config/nano/nanorc
```


```
## Behavior settings
set autoindent
set constantshow
set historylog
set minibar
set positionlog
set tabsize 2
set tabstospaces
set unix

## Show a custom help line at the bottom
unset nohelp
set multibuffer

##  Some colors
set titlecolor brightwhite,blue
set statuscolor brightwhite,blue
set errorcolor brightwhite,red
set selectedcolor black,brightcyan
set stripecolor ,blue
set numbercolor brightcyan
set keycolor brightcyan
set functioncolor brightblue

## Better contrast for text
set constantshow
set linenumbers
set indicator

## Syntax highlighting
include "/usr/share/nano/*.nanorc"

## More intuitive keyboard shortcuts
bind ^Q exit all
bind ^F whereis all
bind ^L findnext all
bind F3 findnext all
bind ^C copy main
bind ^V paste all
bind ^Y cut all
bind ^G gotoline main
bind ^/ comment main

## Help system - F1 opens help screen
bind F1 help all
```
