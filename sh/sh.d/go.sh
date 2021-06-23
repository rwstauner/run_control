if [[ -d ~/go ]]; then
  export GOROOT="$HOME/go"
  add_to_path "$GOROOT/bin"
fi

export GOPATH="$HOME/gopath"
export GO111MODULE="on"
add_to_path "$GOPATH/bin"
