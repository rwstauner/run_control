#!/bin/bash

[[ "$1" == "+x" ]] || set -x
umask 0022

PREFIX=$HOME/usr
SRC_DIR=$HOME/data/src
rc=$HOME/run_control #rc=`dirname $0`/..

arch-info () {
  local bits name
  if uname -m -i -p | sed 's/ /\n/g' | uniq | grep -q x86_64; then
    bits=64
    name=amd64
  else
    bits=32
    name=i386
  fi
  case "$1" in
    bits) echo $bits;;
    name) echo $name;;
    *) echo unknown: "$*";;
  esac
}

download () {
  local url="$1" dest="${2:-${1##*/}}"
  wget --no-clobber "$url" -O "$dest"
}

download-bin () {
  local url="$1" dest="$HOME/usr/bin/${2:-${1##*/}}"
  download "$url" "$dest"
  chmod 0755 "$dest"
}

ensure-line () {
  local line="$1" file="$2"
  grep -qFx "$line" "$file" || \
    echo "$line" | sudo tee -a "$file"
}

expired () {
  local file="$HOME/.cache/$USER-expiry-timestamps/$1" sec="${2:-3600}"
  local stamp=`date +%s`
  if ! [[ -e "$file" ]] || [[ "$(<$file)" -lt `expr $stamp - $sec` ]]; then
    mkdir -p "${file%/*}"
    echo $stamp > "$file"
    return 0
  else
    return 1
  fi
}

have () {
  which "$1" &> /dev/null
}

homebrew-ready () {
  # Always return false if not a mac.
  macosx || return 1

  if ! have brew; then
    echo 'installing homebrew...'
    $rc/install/homebrew
    source $rc/sh/setup.sh
    source $rc/sh/homebrew.sh
  fi

  # Always return true if we _should_ have homebrew (on a mac).
  return 0
}

homebrew () {
  homebrew-ready || return 1

  # Get latest formulae.
  expired 'homebrew-update' && \
    brew update

  if brew ls | grep -qFx "$1"; then
    brew upgrade "$@"
  else
    brew install "$@"
  fi

  # Always return true if we want to install with homebrew
  # (to enable if/block/exit).
  return 0
}

install-fonts () {
  if macosx; then
    for i in "$@"; do
      open "$i"
    done;
  fi
}

macosx () {
  [[ `uname` = Darwin ]]
}

in-group () {
  groups | sed 's/ /\n/g' | grep -q "$@"
}

add-to-group () {
  local group="$1" user="${2:-$USER}"
  echo "Adding $user to $group group"
  sudo usermod -a -G $group $user
}

ensure-in-group () {
  in-group "$1" || add-to-group "$1"
}


git-dir () {
  local tag=false
  [[ "$1" == "--tag" ]] && { tag=true; shift; }
  local url="$1" dir="$2"
  if ! [[ -d "$dir/.git" ]]; then
    git clone "$url" "$dir"
    cd "$dir"
  else
    cd "$dir"
    git checkout master
    git pull
    $tag && git-checkout-latest-tag
  fi
  # Stay in dir.
}

git-checkout-latest-tag () {
  # Checkout latest tag (strip describe's commits since tag).
  # 0.30.0-24-g07f8336 => 0.30.0
  git checkout `git describe --tags | sed -r 's/-[0-9]+-g[0-9a-f]+$//'`
}

versioned-archive-dir () {
  local name="$1" url="$2";
  local basename="${url##*/}"
  local dest="$PREFIX/${basename%.tar.*}"
  local symlink="$name"

  if ! [[ -d "$dest" ]]; then
    (
    cd "${dest%/*}" && \
    # Write to disk instead of pipe to utilize `tar -a`.
    download "$url" && \
    tar -xaf "$archive" && \
    rm -f "$symlink" && \
    ln -s "${dest##*/}" "$symlink" && \
    rm "$archive"
    )
  fi
}

version_ge () {
  perl -e '($s, $t) = map { [split /\./, (/([0-9.]+)/)[0]] } @ARGV; while(@$t){ shift(@$s) >= shift(@$t) or exit(1) }' -- "$@"
}

script () {
  cat > "$1"
  chmod 0755 "$1"
}

setup_runtime_dir () {
  local name="$1" homedir="${2:-$1}"

  local root=$HOME/$homedir
  test -d "$root" || mkdir -p "$root"

  local rcdir=$root/rc
  if ! [[ -d $rcdir ]]; then
    ln -s ~/run_control/$name $rcdir;
  fi
}

zip-file-contents () {
  unzip -qql "$1" | perl -lne 'print $1 if /^\s+\d+\s+[0-9-]+\s+[0-9:]+\s+(.+)/'
}
