#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More;

use JSON::XS qw(decode_json);

use Sport::Analytics::NHL::LocalConfig;
use Sport::Analytics::NHL::Tools;
use Sport::Analytics::NHL::Util;
use Sport::Analytics::NHL::Test;

use t::lib::Util;

test_env();
$ENV{MONGO_DB} = undef;
plan tests => 2;

for my $season (1930, 2016) {
	my $schedule = decode_json(read_file(get_schedule_json_file($season)));
	my $schedule_by_date = {};
	arrange_schedule_by_date($schedule_by_date, $schedule);
	for my $schedule_date (keys %{$schedule_by_date}) {
		for my $game (@{$schedule_by_date->{$schedule_date}}) {
			test_team_id($game->{away}, 'away team ok');
			test_team_id($game->{home}, 'home team ok');
			test_game_id($game->{_id}, 'id is an NHL id', 1);
			test_stage($game->{stage}, 'stage ok');
			test_season($game->{season}, 'season ok');
			test_season_id($game->{season_id}, 'season id ok');
			test_ts($game->{ts}, "$game->{ts} game timestamp ok");
			test_game_id($game->{game_id}, 'game_id is our id');
			test_game_date($game->{date}, 'game date YYYYMMDD');
		}
	}
}

summarize_tests();
