#!/bin/bash

set -x

json_tool="$HOME/usr/bin/json.tool"
if ! [[ -f "$json_tool" ]]; then
  # Use pydoc to find the file.
  jtpy="`pydoc json.tool | awk '{ if( found ){ print $1; exit } } /FILE/ { found=1 }'`"
  if [[ -f "$jtpy" ]]; then
    # Insert a shebang and change the indent level.
    sed -e '1 i #!/usr/bin/env python' -e 's/indent=4/indent=2/' "$jtpy" > "$json_tool"
    # Set exec bit.
    chmod 0755 "$json_tool"
  fi
fi
