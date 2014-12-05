#!/usr/bin/env perl

use strict;
use warnings;
use Perl::Tidy;
use Test::More 0.88;
use Test::Differences;

sub test_tidy {
  my ($src, $exp) = @_;
  my $dst;
  perltidy(
    source      => \$src,
    destination => \$dst,
  );
  eq_or_diff($dst, $exp, 'tidied');
}

test_tidy(
  <<'IN',
my $s1 = { 'ALL' => { 'index' => { 'key' => 'value', }, 'alpine' => {
  'one'=> '+',
  'three' => '+',
}, } };

func('var',
  { 'ALL' => {
    'index' => {
      'key'  => 'value',
    },
    'alpine' => {
      'one'   => '+',
      'three'  => '+',
    },
  },
});

func $thing, {
  k => 'v',
  k2 => 'v2',
};
IN
  <<'OUT',
my $s1 = {
  'ALL' => {
    'index'  => { 'key' => 'value', },
    'alpine' => {
      'one'   => '+',
      'three' => '+',
    },
  }
};

func(
  'var',
  {
    'ALL' => {
      'index' => {
        'key' => 'value',
      },
      'alpine' => {
        'one'   => '+',
        'three' => '+',
      },
    },
  }
);

func $thing, {
  k  => 'v',
  k2 => 'v2',
};
OUT
);

done_testing;
