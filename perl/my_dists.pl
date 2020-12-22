#!/usr/bin/env perl

use strict;
use warnings;
# Stick to core modules.
use Getopt::Long;
use HTTP::Tiny;
use JSON::PP;

sub find_author {
  my $pause = "$ENV{HOME}/.pause";
  if( -r $pause ){
    local @ARGV = $pause;
    while( <> ){
      if( /^user\s+(.+)/ ){
        return $1;
      }
    }
  }
  die "PAUSE id not found.  Use --author\n";
}

my %opts = (
  dists => 1,
);
GetOptions(
  'dists!'        => \$opts{dists},
  'mods|modules!' => sub { $opts{dists} = 0 },
  'author=s'      => \(my $author),
);
$author ||= find_author;

my $ua = HTTP::Tiny->new;

# NOTE: This finds "latest" releases when it may be more desirable to get
# latest dev releases (which requires a more interesting query/filter.
my $query = {
  query  => { match_all => {} },
  filter => {
    and  => [
      { term => { author => $author } },
      { term => { status => 'latest' } },
      $opts{dists} ? () : (
        { term => { "file.module.indexed"    => 1 } },
        { term => { "file.module.authorized" => 1 } },
      ),
    ]
  },
  $opts{dists}
    ? (
        fields => [ 'archive' ],
        size   => 500,
      )
    : (
        fields => [ 'file.module.name' ],
        size   => 5000,
      )
};

  my $search = $opts{dists} ? 'release' : 'module';
  my $res = $ua->request(POST => "http://fastapi.metacpan.org/$search/_search", {
    content => encode_json($query)
  });

my @results = @{ decode_json($res->{content})->{hits}{hits} };

print map { "$_\n" } sort
  $opts{dists}
    ?
      map  { "$author/" . $_->{fields}{archive} }
        @results
    :
      # ignore installed mods
      #grep { !eval "require $_" }
      map  { $_->{fields}{'module.name'} }
        @results
