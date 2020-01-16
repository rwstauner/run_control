#!/usr/bin/env perl

# Adapted from http://bob.cakebox.net/osxcompose/compose2keybindings.pl

use strict;
use warnings;
use 5.010; # defined-or

our %Keysyms;
our $INDENT = '  ';

use charnames ();
use List::MoreUtils qw(firstidx);
use X11::Keysyms '%Keysyms', ('MISCELLANY', 'XKB_KEYS', '3270', 'LATIN1', 'LATIN2', 'LATIN3', 'LATIN4', 'KATAKANA', 'ARABIC', 'CYRILLIC', 'GREEK', 'TECHNICAL', 'SPECIAL', 'PUBLISHING', 'APL', 'HEBREW', 'THAI', 'KOREAN');

binmode $_, ':utf8'
  for \*STDIN, \*STDOUT, \*STDERR;

my %keys;

sub parseline {
  chomp(my $line = shift);

  # Parse line into tokens.
  my @tokens = $line =~ /\"[^\"]+\"|\S+/g;

  # Strip comments.
  for my $i ( 0 .. $#tokens ){
    if( $tokens[$i] =~ /^#/ ){
      splice(@tokens, $i);
      last;
    }
  }

  return unless @tokens;

  # Separate input "events" from output "results".
  my $colonidx = firstidx { $_ eq ':' } @tokens;

  my @events = @tokens[0 .. $colonidx-1];
  my @results = @tokens[$colonidx+1 .. $#tokens];

  # Skip all but combinations starting with multi_key (dead keys).
  return unless $events[0] eq '<Multi_key>';

  # Drop the Compose Key from our struct.
  shift @events;

  # Skip all combinations involving dead keys.
  return if grep { /^<dead_/ } @events;

  # Translate keysyms.
  @events =
    map { /<U([0-9a-fA-F]+)>/ ? hex($1) : $_ }
    map { /<(.*)>/ ? $Keysyms{$1} // $_ : $_ }
      @events;

  # Now skip the combinations if there are unknown keysyms
  return if grep { /^</ } @events;

  @events = map { chr } @events;

  # Decode results.
  my $result;
  if( $results[0] =~ /^"(.*)"$/ ){
    $result = $1;
    $result =~ s/\\([0-7]+)/oct($1)/ge;
    $result =~ s/\\(0x[0-9a-zA-Z]+)/hex($1)/ge;
  }
  else {
    die 'unimplemented case';
  }

  # Create a multilevel hash like this from events:
  # %keys = ( a => { e => 'aelig' } )

  my $ref = \\%keys;
  foreach( @events ){
    # Not sure how to make a sequence return text *and/or* accept more keys.
    return if exists $$ref->{$_} && !ref $$ref->{$_};

    $ref = \$$ref->{$_};
  }

  # Prefer longer sequences over shorter ones.
  $$ref = $result unless ref $$ref;
}

sub indent {
  return ('  ' x $_[0]);
}

sub output {
  my $data = shift;
  my @stack = @_;

  my $indent = @stack;

  # If there's a structure, descend.
  if( ref $data ){
    print "{\n";
    foreach my $key ( sort keys %$data ){
      printf '%s"\U%04X" = ',
        indent($indent + 1),
        ord($key);

      output($data->{$key}, @stack, $key);
    }

    printf "%s};\n", indent($indent);
  }
  # Output the target.
  else {
    printf '("insertText:", "%s"); /* %s: %s */' . "\n",
      $data,
      join(', ', Compose => map { charnames::viacode(ord $_) // 'unknown' } @stack),
      charnames::viacode(ord $data) // '';
  }
}

while(<>){
  parseline($_);
}

output(\%keys);
