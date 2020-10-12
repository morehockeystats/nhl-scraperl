#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use t::lib::Util;
test_env();

use Test::More;
use Sport::Analytics::NHL::Util qw(:debug);
use Sport::Analytics::NHL::Vars qw($DB);

use Sport::Analytics::NHL qw(get_schedule get_games);
plan tests => 9;

my $games = get_games({no_parse => 1}, 1917020001);
is_deeply($games, [{
	'game_id' => 1917020001,
	'season' => 1917,
	'season_id' => 1,
	'stage' => 2,
}], 'correct crawl by id');
my $file = 't/data/1917/0002/0001/BS.json';
ok(-f $file, 'file crawled');
ok(-s $file > 1000, 'some contents are present');
unlink $file;
@ARGV = (1918020001);
$games = get_games({no_parse => 1});
is_deeply($games, [{
	'game_id' => 1918020001,
	'season' => 1918,
	'season_id' => 1,
	'stage' => 2,
}], 'correct crawl by id');
$file = 't/data/1918/0002/0001/BS.json';
ok(-f $file, 'file crawled');
ok(-s $file > 1000, 'some contents are present');
unlink $file;
@ARGV = ();
get_schedule({no_parse => 1, date => 19181221});
$games = get_games({no_parse => 1, date => 19181221});
is_deeply($games, [{
	'game_id' => 1918020001,
	'season' => 1918,
	'season_id' => 1,
	'stage' => 2,
}], 'correct crawl by id');
$file = 't/data/1918/0002/0001/BS.json';
ok(-f $file, 'file crawled');
ok(-s $file > 1000, 'some contents are present');
unlink $file;
END {
    $DB->get_collection('schedule')->drop() if $DB;
}
