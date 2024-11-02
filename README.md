# battery_alert
A lightweight low battery notifier.

Uses `notify-send` from [libnotify](https://gitlab.gnome.org/GNOME/libnotify)

It polls once a minute from `/sys/class/power_supply/...` to detect the battery percentage and pushes a notification when it's under a threshold and not charging.

I use it in conjuction with hyprland:
`exec-once=~/.config/hypr/scripts/battery_alert`

To build:

```zig build -Doptimize=ReleaseSmall r```
