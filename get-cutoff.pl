#!/usr/bin/env perl

use strict;
use warnings;

use v5.14;

use JSON;
use LWP::Simple;

my $locations = shift || die "Usage: $0 locations parameter\n";
my $parameter = shift || "followers";

my @locations = split(",",$locations);
my $locations_url = join("+",map( "location:$_", @locations));

my $id = $ENV{'GH_ID'} || '';
my $secret = $ENV{'GH_ID'} || '';

my $users = 9999;
my $cutoff = 1;
while ( $users > 1000 ) {
  my $url = "https://api.github.com/search/users?client_id=$id&client_secret=$secret&q=$locations_url+followers:%3E$cutoff+sort:followers+type:user&per_page=100&page=1";
  my $result_JSON = get $url;
  my $result = decode_json $result_JSON;
  $users = $result->{'total_count'};
  say "Users $users Cut-off $cutoff";
  $cutoff++ if $users > 1000;
}
say "Cutoff = $cutoff";
