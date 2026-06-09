//  kittymenu — Quickshell context-menu proof of concept
//  =====================================================
//  Place this at:  ~/.config/quickshell/kittymenu/shell.qml
//  Run it with:    qs -p ~/.config/quickshell/kittymenu/shell.qml    (idles invisibly)
//  Trigger it:     qs ipc -p ~/.config/quickshell/kittymenu/shell.qml call menu open <x> <y>
//
//  IMPORTANT: `-c kittymenu` will FAIL if ~/.config/quickshell/shell.qml exists
//  (ML4W ships one). A base shell.qml makes Quickshell ignore all subfolders.
//  Either run by path with -p (as above), or register this in a manifest:
//      ~/.config/quickshell/manifest.conf  ->  kittymenu = kittymenu/shell.qml
//  then `qs -c kittymenu` and `qs ipc -c kittymenu call menu open <x> <y>` work.
//
//  Note the command shape: `qs ipc <selector> call <target> <fn> <args>`.
//
//  Full wiring instructions (kitty binding + cursor wrapper) are at the bottom.
//

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property bool   menuOpen: false
    property int    menuX: 0
    property int    menuY: 0
    property string sock: ""          // KITTY_LISTEN_ON of the window we were opened from
    property string screenName: ""    // name of the monitor the cursor was on

    // Your menu. `cmd` is a shell command run on click; empty cmd just closes.
    // The token {sock} is replaced at click time with the kitty socket address.
    readonly property var items: [
        { label: "New kitty window",     cmd: "kitty" },
        { label: "Paste into terminal",  cmd: "wl-paste --no-newline | kitten @ --to {sock} send-text --stdin" },
        { label: "Copy selection",       cmd: "t=$(kitten @ --to {sock} get-text --extent=selection); printf %s \"$t\" | wl-copy" },
        { label: "Open clipboard URL",   cmd: "u=$(wl-paste); case \"$u\" in http://*|https://*) xdg-open \"$u\" ;; *) notify-send \"Open clipboard URL\" \"The text in the clipboard is not a URL\" ;; esac" },
        { label: "Close",                cmd: "" }
    ]

    // ---- IPC: how kitty (or anything) opens the menu ------------------------
    // Types MUST be explicit or the function won't register with `qs ipc call`.
    IpcHandler {
        target: "menu"
        function open(x: int, y: int, screenName: string, sock: string): void {
            root.menuX = x; root.menuY = y; root.sock = sock;
            root.screenName = screenName;
            // Park the menu on the monitor the cursor is on.
            var screens = Quickshell.screens;
            for (var i = 0; i < screens.length; i++) {
                if (screens[i].name === screenName) { overlay.screen = screens[i]; break; }
            }
            root.menuOpen = true;
        }
        function close(): void { root.menuOpen = false; }
    }

    // ---- one-shot command runner --------------------------------------------
    Process { id: runner }
    function run(command) {
        if (command && command.length > 0) {
            var c = command.replace("{sock}", root.sock);
            runner.command = ["sh", "-c", c];
            runner.running = false;   // reset so a repeated click re-fires
            runner.running = true;
        }
        root.menuOpen = false;
    }

    // ---- the overlay + menu --------------------------------------------------
    PanelWindow {
        id: overlay
        visible: root.menuOpen
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore  // cover the WHOLE screen (incl. behind
                                             // Waybar) so (0,0) matches hyprctl cursorpos
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors { top: true; bottom: true; left: true; right: true }

        // Click anywhere outside the menu closes it.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPressed: root.menuOpen = false
        }

        // Esc closes too.
        Item {
            anchors.fill: parent
            focus: overlay.visible
            Keys.onEscapePressed: root.menuOpen = false
        }

        Rectangle {
            id: menu
            // Clamp to the screen so it stays visible near edges.
            x: Math.max(0, Math.min(root.menuX, overlay.width  - width))
            y: Math.max(0, Math.min(root.menuY, overlay.height - height))
            width: 210
            implicitHeight: col.implicitHeight + 12
            height: implicitHeight
            radius: 10
            color: "#1e1e2e"
            border.color: "#45475a"
            border.width: 1

            // Swallow clicks on the menu itself so the outside handler ignores them.
            MouseArea { anchors.fill: parent }

            Column {
                id: col
                anchors.fill: parent
                anchors.margins: 6
                spacing: 2

                Repeater {
                    model: root.items
                    delegate: Rectangle {
                        required property var modelData
                        width: col.width
                        height: 32
                        radius: 6
                        color: rowMouse.containsMouse ? "#313244" : "transparent"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            text: modelData.label
                            color: "#cdd6f4"
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.run(modelData.cmd)
                        }
                    }
                }
            }
        }
    }
}

/*  ---- WIRING IT UP --------------------------------------------------------

    1) Save as ~/.config/quickshell/kittymenu/shell.qml and start it BY PATH:
           qs -p ~/.config/quickshell/kittymenu/shell.qml &
       It runs invisibly until triggered.

       Why by path? If ~/.config/quickshell/shell.qml exists (ML4W ships one),
       Quickshell ignores all subfolders, so `qs -c kittymenu` fails. Running
       with -p sidesteps that. Check with: ls ~/.config/quickshell/
       Alternatively add a manifest line so -c works:
           ~/.config/quickshell/manifest.conf  ->  kittymenu = kittymenu/shell.qml

    2) A wrapper that reads the cursor position and opens the menu there.
       Save as ~/.config/kitty/show-menu.sh and `chmod +x` it:

           #!/bin/sh
           QS=~/.config/quickshell/kittymenu/shell.qml
           pos=$(hyprctl cursorpos)            # prints e.g. "1234, 567"
           x=$(echo "$pos" | cut -d, -f1 | tr -d ' ')
           y=$(echo "$pos" | cut -d, -f2 | tr -d ' ')
           qs ipc -p "$QS" call menu open "$x" "$y"

    3) Bind right-click in kitty. In ~/.config/kitty/custom.conf:

           mouse_map right press ungrabbed launch --type=background sh -c "~/.config/kitty/show-menu.sh"

       NOTE: this external-trigger line is the part most likely to need
       tweaking on Wayland/Hyprland. Test the wrapper FIRST by binding it to
       a normal Hyprland keybind (or just running show-menu.sh in a terminal)
       to confirm the Quickshell side works. Only then sort out the kitty
       mouse_map — that way you know which half is misbehaving.

    4) For "Paste into terminal", enable kitty remote control in custom.conf
       and match the socket path used in the items list above:

           allow_remote_control yes
           listen_on unix:/tmp/kitty.sock
*/
