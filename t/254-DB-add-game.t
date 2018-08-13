#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More;
use List::MoreUtils qw(uniq);
use Storable;

use JSON;

use Sport::Analytics::NHL::LocalConfig;
use Sport::Analytics::NHL::DB;
use Sport::Analytics::NHL::Tools;
use Sport::Analytics::NHL::Util;
use Sport::Analytics::NHL::Scraper;
use Sport::Analytics::NHL::Report::Player;
use Sport::Analytics::NHL;

use t::lib::Util;

if ($ENV{HOCKEYDB_NODB} || ! $MONGO_DB) {
	plan skip_all => 'Mongo not defined';
	exit;
}
plan qw(no_plan);
test_env();
my $db = Sport::Analytics::NHL::DB->new();
my $hdb = Sport::Analytics::NHL->new();
use Data::Dumper;
$ENV{HOCKEYDB_DEBUG} = $IS_AUTHOR;
my @collections = map($db->get_collection($_), qw(coaches games locations events STOP FAC PENL GOAL TAKE GIVE PEND PSTR GEND HIT MISS BLOCK SHOT shot_types misses stopreasons penalties sntrengths zones));
my $events_c = $db->get_collection('events');
for (201120010, 193020010) {
	my @normalized = $hdb->normalize({data_dir => 't/data/'}, $_);
	my $boxscore = retrieve $normalized[0];
	$boxscore->{location} = $db->create_location({
		name     => $boxscore->{location},
		capacity => $boxscore->{attendance} || 0,
	})->{_id} if $boxscore->{location};
	$db->add_game_coaches($boxscore);
	my @events = ();
	for my $event (@{$boxscore->{events}}) {
		push(@events, $db->create_event($event));
	}
	$boxscore->{events} = [@events];
	$db->add_game($boxscore);
	my $game = $db->get_collection('games')->find_one({_id => $boxscore->{_id}});
	is(scalar(@{$game->{events}}), scalar(@{$boxscore->{events}}), 'all events accounted');
	my $e = 1;
	for (@{$game->{events}}) {
		is($_, $game->{_id}*10000 + $e++, '_id as expected');
		my $_event = $events_c->find_one({event_id => $_ + 0});
		my $event = $db->get_collection($_event->{type})->find_one({
			_id => $_event->{event_id}
		});
		isa_ok($event, 'HASH', 'event accounted correctly');
	}
	my $coaches_c = $db->get_collection('coaches');
	for my $t (0,1) {
		my $team = $game->{teams}[$t];
		my $coach = $coaches_c->find_one({_id => $team->{coach}});
			isa_ok($team->{coach}, 'MongoDB::OID', 'coach registered');
		if ($coach->{name} ne 'UNKNOWN COACH') {
			is(scalar(grep {$_ == $game->{_id}} @{$coach->{games}}), 1, 'coach game registered');
		}
	}
	isa_ok($game->{location}, 'MongoDB::OID', 'location registered')
		if $boxscore->{location};
}

END {
	$_->drop() for @collections;
}
