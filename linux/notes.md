# setup

run appropriate scripts in ./linux/setup

# window manager

wade through settings looking for new things

window manager
- keyboard
  - behvaior
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

    GRUB_CMDLINE_LINUX_DEFAULT="quiet splash resume=/dev/nvme0n1p7"
