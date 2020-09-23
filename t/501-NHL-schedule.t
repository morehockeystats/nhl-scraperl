#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use t::lib::Util;
test_env();

use Test::More;
use Sport::Analytics::NHL::Vars qw($DB);
use Sport::Analytics::NHL::Util qw(:debug);
use Sport::Analytics::NHL;

plan tests => 2;

my $opts = {date => '20200110'};
my $games = get_schedule($opts);
my $db_games = [ $DB->get_collection('schedule')->find()->all() ];
delete $_->{_id} for @{$db_games};
is_deeply($games, $db_games, 'games from the database');
ok(scalar @{$games}, 'some games');
END {
    $DB->get_collection('schedule')->drop() if $DB;
}
