#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Storable qw(dclone);
use Date::Format;

use Test::More;

use Sport::Analytics::NHL::Vars   qw($CURRENT_SEASON);
use Sport::Analytics::NHL::Config qw($FIRST_SEASON);
use Sport::Analytics::NHL::Util   qw(:debug);
use Sport::Analytics::NHL::Usage;

plan tests => 9;

my $opts = {};
my $today     = time2str("%Y%m%d", time);
my $yesterday = time2str("%Y%m%d", time-86400);
$opts->{date} = ['today'];
Sport::Analytics::NHL::Usage::order_date_opts($opts, 'date');
is_deeply($opts, {date => [$today]}, 'date today converted to number');
$opts->{date} = ['today', 'yesterday'];
Sport::Analytics::NHL::Usage::order_date_opts($opts, 'date');
is_deeply($opts, {date => [$yesterday, $today]}, 'date today, yesterday converted to number and ordered');
$opts->{week} = [4,5,1];
Sport::Analytics::NHL::Usage::order_date_opts($opts, 'week');
is_deeply($opts, {date => [$yesterday, $today], week => [1,4,5]}, 'weeks ordered');
$opts = { start_game_id => 12, stop_game_id => 15, week => [4,5,1] };
Sport::Analytics::NHL::Usage::order_date_opts($opts, 'game_id', 1);
is_deeply($opts, {start_game_id => 12, stop_game_id => 15, game_id => [12..15], week => [4,5,1]}, 'game_ids ordered, weeks ignored');
$opts = {season => 2005};
Sport::Analytics::NHL::Usage::parse_date_opts($opts);
is_deeply($opts, {season => [2005]}, 'single opt converted to arrayref');
$opts = {season => 2005};
$opts->{date} = ['today', 'yesterday'];
Sport::Analytics::NHL::Usage::parse_date_opts($opts);
is_deeply($opts, {date => [$yesterday, $today]}, 'date processed, season erased');
$opts = {start_season => 2002};
Sport::Analytics::NHL::Usage::parse_date_opts($opts);
is_deeply($opts, {season => [2002..$CURRENT_SEASON]}, 'start stop seasons defaulted and processed');
$opts = {start_date => 'yesterday', season => 2018};
Sport::Analytics::NHL::Usage::parse_date_opts($opts);
is_deeply($opts, {date => [$yesterday, $today]}, 'date options processed');
$opts = {start_game_id => 201220001};
eval { Sport::Analytics::NHL::Usage::parse_date_opts($opts) };
like($@, qr/Start or stop values are unavailable for option game/, 'need both start and stop for game id')