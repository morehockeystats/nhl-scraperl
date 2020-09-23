#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use t::lib::Util;
test_env();

use Storable qw(dclone);
use Test::More;

use Sport::Analytics::NHL::Vars qw($DB);

use Sport::Analytics::NHL::Schedule;
plan tests => 9;

my $schedule = Sport::Analytics::NHL::Schedule->new();
my @games = $schedule->load_from_db({date => 20200202});
is(scalar(@games), 0, 'no games yet in db');
@games = $schedule->load_from_fs({date => 20200202});
is(scalar(@games), 0, 'no games yet in fs');
@games = $schedule->load_from_fs({season => 2020});
is(scalar(@games), 0, 'no games yet in fs');
my $game = [{
    'away' => 'OTT',
    'date' => 20200110,
    'feed' => '/api/v1/game/2019020689/feed/live',
    'game_id' => 2019020689,
    'home' => 'DET',
    'season' => 2019,
    'season_id' => 689,
    'stage' => 2,
    'status' => 'Final',
    'ts' => 1578702600,
    'year' => 2020,
}];
my $tmp_schedule = "t/data/2019/schedule.json";
$schedule->{data} = dclone $game;
$schedule->{config}{season} = 2019;
my $res;
$res = $schedule->save_to_fs();
is($res, 0, 'save to fs successful');
$schedule->{data} = [$schedule->load_from_fs()];
is_deeply($schedule->{data}, $game, 'load from fs successful');
$DB->get_collection('schedule')->drop() if $DB;
$res = $schedule->save_to_db();
is($res, 0, 'save to db successful');
$schedule->{data} = [$schedule->load_from_db()];
delete $schedule->{data}[0]{inserted};
delete $schedule->{data}[0]{_id};
is_deeply($schedule->{data}, $game, 'load from db successful');
$DB->get_collection('schedule')->drop() if $DB;
$res = $schedule->save(1);
is_deeply($schedule->{data}, [], 'data wiped');
$schedule->load();
delete $schedule->{data}[0]{inserted};
delete $schedule->{data}[0]{_id};
is_deeply($schedule->{data}, $game, 'abstract load successful');


END {
    unlink $tmp_schedule if $tmp_schedule;
    $DB->get_collection('schedule')->drop() if $DB;
}
