#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use t::lib::Util;

use Sport::Analytics::NHL::Vars qw($DB);
use Sport::Analytics::NHL::Util qw(:debug);
use Sport::Analytics::NHL::Config qw(%TEAMS);

use Test::More;

use Sport::Analytics::NHL::Schedule;

plan tests => 10;
test_env();

my $schedule = Sport::Analytics::NHL::Schedule->new({date => 20200109});
$schedule->{data} = [{
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
my $res;
$res = $schedule->save_to_fs();
is($res, 1, 'cannot save to fs by date');
$schedule->{config}{season} = 1;
$res = $schedule->save_to_fs();
is($res, 0, 'save successful');
my $tmp_schedule = "t/data/2019/schedule.json";
ok(-f $tmp_schedule, 'file created');
is(-s $tmp_schedule, 194, 'file has correct size');
$schedule->save_to_db();
my $games = [ $DB->get_collection('schedule')->find()->all() ];
my $ts = $games->[0]{inserted};
like($ts, qr/^\d{10}$/, 'timestamp attached');
my $_id = delete $games->[0]{_id};
is(length($_id), 24, '_id created');
is_deeply($games, $schedule->{data}, 'data preserved');
$DB->get_collection('schedule')->drop();
$schedule->save;
$games = [ $DB->get_collection('schedule')->find()->all() ];
$ts = $games->[0]{inserted};
like($ts, qr/^\d{10}$/, 'timestamp attached');
$_id = delete $games->[0]{_id};
is(length($_id), 24, '_id created');
is_deeply($games, $schedule->{data}, 'data preserved');

END {
    unlink $tmp_schedule if $tmp_schedule;
    $DB->get_collection('schedule')->drop() if $DB;
}
