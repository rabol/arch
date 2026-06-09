# kitty context menu (Quickshell)

A right-click context menu for the [kitty](https://sw.kovidgoyal.net/kitty/)
terminal, drawn with [Quickshell](https://quickshell.org/) on Hyprland/Wayland.

kitty deliberately has no built-in GUI context menu. This project adds one:
right-click anywhere in a kitty window and a small menu appears **at the cursor,
on the correct monitor**, with working copy / paste / open-URL actions that
target the exact terminal you clicked in.

> Built and tested on Hyprland with the ML4W dotfiles. It should work on any
> Hyprland setup; other wlroots compositors will need the cursor/monitor
> helpers adapted (see *How it works*).

## Demo

Right-click in kitty → menu at the pointer → pick an action.

Default items: **New kitty window**, **Paste into terminal**, **Copy selection**,
**Open clipboard URL**, **Close**. All easy to edit (see *Customising*).

## Requirements

| Tool | Why | Arch package |
|------|-----|--------------|
| Hyprland | cursor position + monitor geometry (`hyprctl`) | `hyprland` |
| Quickshell | renders the menu | `quickshell` (AUR / your distro) |
| kitty | the terminal + remote control | `kitty` |
| jq | parse `hyprctl … -j` JSON | `jq` |
| wl-clipboard | `wl-copy` / `wl-paste` | `wl-clipboard` |
| xdg-utils | `xdg-open` for the URL item | `xdg-utils` |
| libnotify | `notify-send` feedback | `libnotify` |

```sh
sudo pacman -S quickshell kitty jq wl-clipboard xdg-utils libnotify
```

(`quickshell` may be in the AUR depending on your distro/repos.)

## Files

- `shell.qml` — the Quickshell config (the menu itself).
- `show-menu.sh` — the wrapper kitty runs on right-click: it finds the cursor,
  the monitor, and the kitty socket, then opens the menu over Quickshell IPC.

## Install

### 1. Quickshell config

```sh
mkdir -p ~/.config/quickshell/kittymenu
cp shell.qml ~/.config/quickshell/kittymenu/shell.qml
```

### 2. Wrapper script

```sh
cp show-menu.sh ~/.config/kitty/show-menu.sh
chmod +x ~/.config/kitty/show-menu.sh
```

### 3. kitty config

Add the following to your `kitty.conf` (ML4W users: put it in
`~/.config/kitty/custom.conf`, which is already `include`d):

```conf
# Remote control, so the menu can paste into / read from the terminal.
allow_remote_control yes
listen_on unix:/tmp/kitty.sock

# Right-click opens the menu. If you previously had
#   mouse_map right press ungrabbed paste_from_selection
# replace that line with this one (both bind right-click):
mouse_map right press ungrabbed launch --type=background sh -c "~/.config/kitty/show-menu.sh"
```

> `listen_on` only opens the socket at startup, so **fully restart kitty**
> (close every window / `pkill -x kitty`, then relaunch) after adding it.
> A config reload (`ctrl+shift+f5`) is enough for the `mouse_map` line, but not
> for `listen_on`.

### 4. Run the menu

```sh
qs -p ~/.config/quickshell/kittymenu/shell.qml &
```

It idles invisibly until triggered. To start it automatically, add to your
Hyprland config:

```conf
exec-once = qs -p ~/.config/quickshell/kittymenu/shell.qml
```

> **Why `-p` and not `-c kittymenu`?** If a `shell.qml` exists at the *base* of
> `~/.config/quickshell/` (ML4W ships one), Quickshell treats it as the default
> config and ignores all subfolders, so `-c kittymenu` fails. Running by path
> with `-p` avoids that. Alternatively, add a line to
> `~/.config/quickshell/manifest.conf`:
> ```
> kittymenu = kittymenu/shell.qml
> ```
> and `-c kittymenu` will work.

### 5. Use it

Right-click inside a kitty window.

## How it works

The chain from click to action:

1. **Trigger.** kitty's `mouse_map … launch --type=background` runs
   `show-menu.sh` in the context of the focused window.
2. **Locate.** The wrapper asks Hyprland for the cursor position
   (`hyprctl cursorpos`, global coordinates) and the monitor it sits on
   (`hyprctl monitors -j`), converting the global position to monitor-local
   coordinates. Monitor dimensions are divided by `scale` so the hit-test is
   correct on fractional-scaled displays.
3. **Find the socket.** kitty's `listen_on` appends the kitty **PID** to the
   socket path, and Hyprland reports that same PID as the focused window's
   `pid`. So the wrapper builds the address as
   `unix:/tmp/kitty.sock-<pid>` — a filesystem socket any process can reach.
   (Reading `$KITTY_LISTEN_ON` does **not** work here: a `launch` child only
   gets a process-local fd socket, which can't be handed to another process.)
4. **Open.** The wrapper calls
   `qs ipc -p … call menu open <x> <y> <monitor> <socket>`.
5. **Render.** `shell.qml` parks the menu on the named monitor and stores the
   socket. The overlay uses `ExclusionMode.Ignore` so it spans the **whole**
   screen (including behind any bar) — that makes its origin match where
   `cursorpos` measures from, so the menu lands exactly at the pointer.
6. **Act.** Each menu item is a shell command. The `{sock}` token is replaced
   at click time, so copy/paste hit the exact terminal via
   `kitten @ --to <socket>`.

### Newline handling

Two separate sources add stray newlines, both handled:

- **Copy:** `get-text` appends a trailing newline. Command substitution
  (`t=$(…); printf %s "$t"`) strips all trailing newlines while keeping
  internal ones.
- **Paste:** `wl-paste` appends a newline by default, suppressed with
  `--no-newline`.

## Customising

Edit the `items` array near the top of `shell.qml`. Each entry is
`{ label, cmd }`; `cmd` is a shell command, and `{sock}` expands to the kitty
socket. An empty `cmd` just closes the menu.

```qml
{ label: "My action", cmd: "kitten @ --to {sock} … ; some-other-command" },
```

Colours are currently hardcoded (Catppuccin-ish). If you use a wallpaper-derived
palette (e.g. matugen), point the colours at your generated file instead.

## Troubleshooting

**Right-click does nothing.** Run `kitty --debug-input` and right-click —
confirm the press is seen and the mapped action fires. Check
`~/.config/kitty/show-menu.sh` is executable and the `qs` instance is running.

**Copy / paste do nothing.** Confirm `allow_remote_control yes` and `listen_on`
are set, then **fully restart** kitty (the socket only opens at launch). Verify
the socket exists: `ls /tmp/kitty.sock*` — note the real name has a `-<pid>`
suffix, so `ls /tmp/kitty.sock` alone will say "no such file".

**Menu appears at the wrong spot.** Make sure the overlay uses
`exclusionMode: ExclusionMode.Ignore`. If it respects exclusion zones it gets
pushed below your bar and lands ~one bar-height too low.

**No notification on a non-URL clipboard.** Ensure a notification daemon
(dunst, mako, swaync…) is running and libnotify is installed:
`notify-send test` should pop a notification.

## License

MIT — see `LICENSE` (add one if you haven't). Adjust to taste.
