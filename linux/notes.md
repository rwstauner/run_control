# setup

run appropriate scripts in ./linux/setup

confirm ctrl-alt-f1-7 works

# window manager

wade through settings looking for new things

window manager
- keyboard
  - behavior
    - num lock state
  - application shortcuts
    - ctrl shift v: xfce4-popup-clipman
    - prt scr: xfce4-screenshooter -r -s /home/rwstauner/Dropbox/Screenshots
  - clipman
    - sync mouse selections
    - shift+insert
- session and startup
  - add entry for ~/.xsession ?
- fiddle with screensaver/power settings to get suspend, etc correct
- get backlight set upon start

# power management

## hibernate

### polkit

    ./linux/setup/hibernate

### grub

    sudo fdisk -l

find swap partition
add it to /etc/default/grub:

    GRUB_CMDLINE_LINUX_DEFAULT="... resume=/dev/nvme0n1p7"

(the `_DEFAULT` is for normal boots only.)

Also comment out

    GRUB_DISABLE_RECOVERY=true

To add a menu entry for single-user mode (1).

To boot into multi-user non-gui mode edit the command line and replace single
with 3.

then

    sudo update-grub
