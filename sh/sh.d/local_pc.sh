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

notify_result () {
  local rv=$?
  local dir=`pwd`

  if [[ $rv -eq 0 ]]; then
    local pf=Passed
    local sound="$HOME/data/audio/angry_birds/angry_birds-cheer_1.ogg"
    local player=ogg123
  else
    local pf=Failed
    local sound="$HOME/data/audio/Super_Mario_Bros_Game_Over_8b6975.mp3"
    local player=mpg123
  fi

  local img="$HOME/data/images/icons/tux.png"
  if [[ "$1" == "-i" ]]; then
    img="$2"; shift 2;
  fi

  if [[ -z "$NO_SOUND" ]] && [[ -e "$sound" ]]; then
    # play sound async without showing anything on screen
    { $player $sound & disown; } &> /dev/null
  fi

  # show pop-up notification
  /usr/bin/notify-send -i "$img" "Tests: $pf" "$dir"

  # preserve exit status
  return $rv
}
