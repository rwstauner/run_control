# Functions that will be used when working at a local pc (not remote sessions).

# draw a box around a message
  box_msg () {
#    if [[ $# -ne 1 ]]; then
      # TODO: wrap to $COLUMNS
      perl -MList::Util=max,min -e 'chomp(@lines = @ARGV ? @ARGV : <STDIN>); $len = max map { length } @lines; $len = min($ENV{COLUMNS}, $len) if $ENV{COLUMNS}; print $b = "-" x ($len + 4) . "\n"; printf("| %-${len}s |\n",$_) for @lines; print $b;' "$@"
#    fi
#    local msg="$1" border="------------------------------------------------------------"
#    local len=$((${#msg}+4))
#    border="${border:0:$len}"
#    echo "$border"
#    echo "| $msg |"
#    echo "$border"
  }

alias nosound='NO_SOUND=1'

# run after a command to notify about its result:
# something () { command something "$@"; notify_result -i "path/to/image"; }
notify_result () {
  local rv=$?
  local dir=`pwd`

  if [[ $rv -eq 0 ]]; then
    local pf=Passed
    local sound="$HOME/data/audio/angry_birds/angry_birds-cheer_1.ogg"
  else
    local pf=Failed
    local sound="$HOME/data/audio/Super_Mario_Bros_Game_Over_8b6975.mp3"
  fi

  local img="$HOME/data/images/icons/tux.png"
  if [[ "$1" == "-i" ]]; then
    img="$2"; shift 2;
  fi

  if [[ -z "$NO_SOUND" ]] && [[ -e "$sound" ]]; then
    # play sound async without showing anything on screen
    # play(1) must be nohup(1)ed or it will pause when backgrounded.
    { nohup play -v 0.5 $sound & disown; } &> /dev/null
  fi

  # show pop-up notification
  local title="Tests: $pf" msg="$dir"
  if which terminal-notifier > /dev/null; then
    terminal-notifier -message "$msg" -appIcon "$img" -title "$title"
  else
    /usr/bin/notify-send -i "$img" "$title" "$msg"
  fi

  # preserve exit status
  return $rv
}
