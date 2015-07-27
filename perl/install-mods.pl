#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use FindBin '$Bin';

$SIG{INT} = sub { die $_[0] };

my @test_reports = qw(
  Test::Reporter::Transport::Socket
  CPAN::Reporter
);

# AnyEvent uses live DNS tests and my stupid ISP DNS is overly helpful.
my @problem_modules = qw(
  AnyEvent
  Net::Server::PreFork
);

my @install_groups;
{
  my $group = 0;
  local @ARGV = "$Bin/install.txt";
  while( <> ){
    s/^\s+//;
    s/\s+$//;

    # Use comments and blank lines to separate groups.
    ++$group, next if /^\s*(#.+)?$/;

    push @{ $install_groups[$group] ||= [] }, $_;
  }
  $install_groups[$group + 1] = [`$Bin/my_dists.pl -d`];
}
{
  my $i = -1;
  while( ++$i < @install_groups ){
    next if $install_groups[$i] && @{ $install_groups[$i] };
    splice(@install_groups, $i, 1);
    redo;
  }
}
chomp(@$_) for @install_groups;

# Don't prompt me.
close STDIN;
open STDIN, '<', '/dev/null';

sub run {
  print "  run: @_\n";
  my $s = system { $_[0] } @_;
  printf "  exit(%s/%s): %s\n", $s, $? >> 8, join ' ', @_;
  return ($s == 0);
}

# NOTE: We basically ignore the result of the cpan calls... most modules
# should get installed eventually... if there's a big problem we'll notice.
my $cpan = 'cpan';
(my $perlbin = $^X) =~ s{[^/]+$}{};
sub cpan {
  run( "$perlbin/$cpan", @_ );
}

# Reset to default in case ENV specifies one we don't have installed.
local $ENV{HARNESS_SUBCLASS} = 'TAP::Harness';

# Avoid any pod tests when we try to install stuff.
cpan( qw/TAP::Harness::Restricted/ ) and
  local $ENV{HARNESS_SUBCLASS} = 'TAP::Harness::Restricted';

# Setup test reports before installing anything else.
cpan( @test_reports );

# some things need forcing
cpan( -f => @problem_modules )
  if @problem_modules;

# Install the rest (retry to catch any circularity problems).
cpan( @$_ )
  for (@install_groups) x 2;
