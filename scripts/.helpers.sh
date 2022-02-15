#!/bin/bash

[[ "$1" == "+x" ]] || set -x
umask 0022

PREFIX=$HOME/usr
mkdir -p $PREFIX/bin
SRC_DIR=$HOME/data/src
rc=$HOME/run_control #rc=`dirname $0`/..
TAR="$(command -v gtar || echo tar)"

source $rc/sh/setup.sh

iif () {
  if eval "$1"; then echo "$2"; else echo "$3"; fi
}

warn () {
  echo "$*" >&2
}

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

cache_dir="$HOME/.cache/$USER-rc-cache"
download () {
  local url="$1" dest="$2"
  local key=`echo "$1" | sed "s,/,%,g"`
  local cache_file="$cache_dir/download/$key"

  if expired "$key" 86400 || ! [[ -f "$cache_file" ]]; then
    mkdir -p "${cache_file%/*}"
    wget --no-clobber "$url" -O "$cache_file"
  fi
  [[ -n "$dest" ]] && cp "$cache_file" "$dest"
  echo "$cache_file"
}

download-bin () {
  local url="$1" dest="$HOME/usr/bin/${2:-${1##*/}}"
  download "$url" "$dest"
  chmod 0755 "$dest"
}

extract () {
  local file="$1" dir=`mktemp -d -t extract-${1##*/}-XXXXXX`
  [[ "${file}" = /* ]] || file="$PWD/$file"
  cd "$dir"
  case "$file" in
    *.tar.*|*.tgz)
      $TAR -xvaf "$file";;
    *.zip)
      unzip "$file";;
    *)
      echo 'unknown archive format' >&2
      return 1
  esac
}

cached () {
  cat "$cache_dir/$1" 2>&-
}
cache () {
  local cache_file="$cache_dir/$1"
  mkdir -p "${cache_file%/*}"
  tee "$cache_file"
}

latest-github-dl-url () {
  local prefix="https://github.com" slug="$1" suffix="${2}"
  key="github-latest/$slug/$suffix"
  ! expired "$key" 86400 && cached "$key" && return

  local url=$(curl -sL "$prefix/$slug/releases/latest" | \
    PREFIX="$prefix" SLUG="$slug" SUFFIX="$suffix" \
    perl -lne 'print(substr($1,0,1) eq "/" ? "$ENV{PREFIX}$1" : $1) if m{href="(.*?/\Q${ENV{SLUG}}\E/releases/download/.+?\Q${ENV{SUFFIX}}\E)"}')

  if [[ -z "$url" ]]; then
    warn "failed to find latest github download url for $slug '$suffix'"
    return 1
  fi

  echo "$url" | cache "$key"
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
  command -v "$1" &> /dev/null
}

homebrew-ready () {
  if ! have brew; then
    echo 'installing homebrew...'
    $rc/install/homebrew
    source $rc/sh/setup.sh
    source $rc/sh/homebrew.sh
  fi

  return 0
}

# avoid shell alias.
function brew () {
  command caffeinate -- brew "$@"
}

homebrew () {
  homebrew-ready || return 1

  # Get latest formulae.
  expired 'homebrew-update' && \
    brew update

  brew install "$@"
  brew upgrade "$@"

  # Always return true if we want to install with homebrew
  # (to enable if/block/exit).
  return 0
}

homebrew-tap () {
  brew tap | grep -qFx "$1" || \
    brew tap "$1"
}

# TODO: apt helpers to only install when not present

install-fonts () {
  if is_mac; then
    for i in "$@"; do
      open "$i"
    done;
  fi
}

is_mac () {
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
    mkdir "$dest" && \
    $TAR -xaf "$basename" --strip-components=1 -C "$dest" && \
    rm -f "$symlink" && \
    ln -s "${dest##*/}" "$symlink" && \
    rm "$basename"
    )
  fi
}

version_ge () {
  # python -c 'import sys; from packaging import version; sys.exit(0 if version.parse(sys.argv[1]) >= version.parse(sys.argv[2]) else 1);' "$@"
  perl -e 'use version 0.77; ($s, $t) = map { version->declare((/([0-9.]+)/)[0]) } @ARGV; exit($s >= $t ? 0 : 1)' -- "$@"
}

script () {
  mkdir -p "`dirname "$1"`"
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
