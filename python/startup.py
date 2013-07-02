# pylint: disable=unused-import, unused-variable, missing-docstring

def _readline():
  try:
    import readline
  except ImportError:
    print("Module readline not available.")
  else:
    import rlcompleter
    readline.parse_and_bind("tab: complete")

    import os
    histfile = os.path.join(os.environ["HOME"], '.python_history')
    try:
      readline.read_history_file(histfile)
    except IOError:
      pass

    import atexit
    atexit.register(readline.write_history_file, histfile)
    del os, histfile

_readline()
del _readline

import sys
sys.ps1 = "\001\033[01;33m\002>>>\001\033[00m\002 "
sys.ps2 = "\001\033[01;33m\002...\001\033[00m\002 "
