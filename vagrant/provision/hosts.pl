#!/usr/bin/env perl

use strict;
use warnings;

-d "/vagrant" or die "Only run in vagrant box";

{
  my ($addr, $name, $file) = qw( 10.0.2.2 vagrant-host /etc/hosts );
  my $matched = 0;

  my @lines = do {
    open(my $fh, "<", $file) or die "read $file: $!";
    <$fh>;
  };

  for ( @lines ) {
    if( /^\s*\Q$addr\E\s/ ){
      /\b\Q$name\E\b/
        # If $name not present insert between previous names and any comments.
        or s/(#.*)?$/ $name $1/;
      ++$matched;
    }
  }

  $matched
    or push @lines, "\n# nat\n$addr $name\n";

  {
    open(my $fh, ">", $file) or die "write $file: $!";
    print $fh @lines;
  }
}
