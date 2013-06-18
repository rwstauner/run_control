#!/usr/bin/env python

# pylint: disable=missing-docstring

from __future__ import print_function
from os import path
import re
import subprocess
import sys

IGNORE = '({0})'.format('|'.join((
  'logilab',
  'Jinja2',
  # markdown ?
  'MarkupSafe',
  'pika',
  # fabric
  'paramiko',
)))

class Matcher():
  def __init__(self, line):
    self.line = line
    self.matched = None

  def match(self, pattern, flags=0):
    self.matched = re.match(pattern, self.line, flags)
    return self.matched

  # Delegate other methods to the match object.
  def __getattr__(self, name):
    return getattr(self.matched, name)

def reqs():
  process = subprocess.Popen(['pip', 'freeze', '-l'], stdout=subprocess.PIPE)
  lines = process.stdout.readlines()
  #if process.wait() == 0:
  return lines

def format_line(line):
  m = Matcher(line.strip())

  if m.match(r'''^
    (?P<dev>      -e\s                        )?
    (?P<scheme>   git(?:\+\w+)?://|git\+git@  )
    (?P<url>      .+?                         )
    (?P<tag>      @.+                         )?
    (?P<egg>      [#]egg=                     )
    (?P<eggname>  .+?                         )
    (?P<eggdev>   -dev                        )?
  $''', re.X):
    return "\n".join([
      '# {0}'.format(m.line),
      re.sub(r'(git\+)+', r'\1',
        '{dev}git+{scheme}{url}{egg}{eggname}'.format(**m.groupdict()),
      )
    ])
  elif m.match(r'^(\S+)==(.+)$'):
    return '{0:20s} >=  {1}'.format(*m.group(1, 2))
  else:
    return line

def lines():
  return [format_line(r) for r in reqs() if not re.match(IGNORE, r)]

def diff():
  process = subprocess.Popen(
    ['diff', '-iwBdu', path.join(path.dirname(__file__), 'requirements.txt'), '-'],
    stdin=subprocess.PIPE,
  )
  process.stdin.write(text())

def show():
  print(text(),)

def text():
  return "".join(l + "\n" for l in lines())

# nose knows to run this test
def test():
  from nose.tools import assert_multi_line_equal
  def t(spec, exp):
    assert_multi_line_equal(format_line(spec), "# {0}\n{1}".format(spec, exp))

  t(
    '-e git://github.com/nvie/nose-machineout.git@903bbc46263b0bed29939d9445316a82f55b747a#egg=nose_machineout-dev',
    '-e git+git://github.com/nvie/nose-machineout.git#egg=nose_machineout',
  )
  t(
    '-e git+git://github.com/nvie/nose-machineout.git#egg=nose_machineout',
    '-e git+git://github.com/nvie/nose-machineout.git#egg=nose_machineout',
  )
  t(
    '-e git+https://github.com/bitprophet/rudolf#egg=rudolf',
    '-e git+https://github.com/bitprophet/rudolf#egg=rudolf',
  )


if __name__ == '__main__':
  if len(sys.argv) == 2 and sys.argv[1] in vars():
    vars()[sys.argv[1]]()
  else:
    show()
