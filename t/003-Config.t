#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More;
plan tests => 324;

use Sport::Analytics::NHL::Config qw(:all);
use Sport::Analytics::NHL::Vars qw($CURRENT_SEASON);

ok(defined $FIRST_SEASON,    'first season defined');
ok(scalar(@LOCKOUT_SEASONS), 'lockout seasons defined');

for my $team (keys %TEAMS) {
	like($team, qr/^[A-Z]{3}/, 'team id three digit code');
	for my $key (keys %{$TEAMS{$team}}) {
		next if $key eq 'timeline';
		if ($key eq 'founded' || $key eq 'folded') {
			like($TEAMS{$team}->{$key}, qr/^\d{4}$/, 'founded is a year');
		}
		elsif ($key eq 'defunct') {
			like($TEAMS{$team}->{$key}, qr/^0|1$/, 'defunct is 0 or 1');
		}
		elsif ($key eq 'color') {
			like($TEAMS{$team}->{$key}, qr/^\w+/, 'color is a word');
		}
		elsif ($key eq 'twitter' || $key eq 'hashtag') {
			like($TEAMS{$team}->{$key}, qr/^\@|\#\w+/, 'hashtag / @ for twitter');
		}
		else {
			isa_ok($TEAMS{$team}->{$key}, 'ARRAY', "a list of alternative $key for team $team");
		}
	}
}
