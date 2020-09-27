#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use t::lib::Util;
test_env();

use Sport::Analytics::NHL::Vars qw($IS_AUTHOR);
use Sport::Analytics::NHL::Util qw(:debug);
use Sport::Analytics::NHL::Config qw(%TEAMS);

use Test::More;
use JSON qw(encode_json);

use Sport::Analytics::NHL::Schedule;
plan tests => 185;

$ENV{HOCKEYDB_DEBUG} = $IS_AUTHOR;
my $schedule = Sport::Analytics::NHL::Schedule->new({date => 20200109});
my $game = {
    game_id => 2019020689,
    feed    => '/api/v1/game/2019020689/feed/live',
    date    => '2020-01-10',
    ts      => '2020-01-11T00:30:00Z',
    away    => 'Ottawa Senators',
    home    => 'Detroit Red Wings',
    status  => 'Final',
};
my $expected_game = {
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
};
Sport::Analytics::NHL::Schedule::process_scheduled_game($game);
is_deeply($game, $expected_game, 'game processed correctly');

my $schedule_game = {
    'content' => { 'link' => '/api/v1/game/2019020689/content' },
    'gameDate' => '2020-01-11T00:30:00Z',
    'gamePk' => 2019020689,
    'gameType' => 'R',
    'link' => '/api/v1/game/2019020689/feed/live',
    'season' => '20192020',
    'status' => {
        'abstractGameState' => 'Final',
        'codedGameState' => '7',
        'detailedState' => 'Final',
        'startTimeTBD' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
        'statusCode' => '7',
    },
    'teams' => {
        'away' => {
            'leagueRecord' => {
                'losses' => 22,
                'ot' => 6,
                'type' => 'league',
                'wins' => 16,
            },
            'score' => 2,
            'team' => {
                'id' => 9,
                'link' => '/api/v1/teams/9',
                'name' => 'Ottawa Senators',
            },
        },
        'home' => {
            'leagueRecord' => {
                'losses' => 30,
                'ot' => 3,
                'type' => 'league',
                'wins' => 12,
            },
            'score' => 3,
            'team' => {
                'id' => 17,
                'link' => '/api/v1/teams/17',
                'name' => 'Detroit Red Wings',
            },
        },
    },
    'venue' => {
        'id' => 5145,
        'link' => '/api/v1/venues/5145',
        'name' => 'Little Caesars Arena',
    },
};
$schedule->populate_scheduled_game($schedule_game, '2020-01-10');
is(scalar(@{$schedule->{data}}), 1, '1 in data populated');
is_deeply($schedule->{data}[-1], $expected_game, 'direct game population ok');
my $schedule_json = encode_json({dates => [
    { date => '2020-01-10', games => [
        $schedule_game,
    ]}
]});
$schedule->populate($schedule_json);
is(scalar(@{$schedule->{data}}), 2, '2 in data populated');
is_deeply($schedule->{data}[-1], $expected_game, 'direct game population ok');
$schedule->crawl_by_date(20200110);
is(scalar(@{$schedule->{data}}), 5, '5 in data populated');
for my $g (@{$schedule->{data}}) {
    is($g->{date}, 20200110, 'correct date');
    ok($TEAMS{$g->{away}}, 'valid resolved away team');
    ok($TEAMS{$g->{home}}, 'valid resolved home team');
}
$schedule->{data} = [];
$schedule->crawl_by_season(1917);
is(scalar(@{$schedule->{data}}), 43, '43 in 1917/18 data populated');
for my $g (@{$schedule->{data}}) {
    like($g->{date}, qr/^191(7|8)/, 'correct date');
    ok($TEAMS{$g->{away}}, 'valid resolved away team');
    ok($TEAMS{$g->{home}}, 'valid resolved home team');
}
$schedule->{data} = [];
$schedule->crawl();
is(scalar(@{$schedule->{data}}), 11, '11 in 20200109 data populated');
for my $g (@{$schedule->{data}}) {
    is($g->{date}, 20200109, 'correct date');
    ok($TEAMS{$g->{away}}, 'valid resolved away team');
    ok($TEAMS{$g->{home}}, 'valid resolved home team');
}
