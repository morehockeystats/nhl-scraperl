#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Vars qw($DEFAULT_STORAGE $DEFAULT_MONGO_DB $CACHES $DB);
use Sport::Analytics::NHL::DB;

if ($ENV{HOCKEYDB_NODB} || $DEFAULT_STORAGE ne 'mongo') {
	plan skip_all => 'Mongo not defined';
	exit;
}
plan tests => 10;

my $db = Sport::Analytics::NHL::DB->new();

my $coll = $db->get_collection('coll');
is_deeply($coll, $CACHES->{collections}{coll}, 'collection cached');

my $query = {};
my $opts = { xyz => 'ad', abc => "12" };
my $field =  'abc';

Sport::Analytics::NHL::DB::convert_field_to_number_list($query, $opts, $field);
is_deeply($query, {abc => {'$in' => [12]} }, 'convert field to number ok');

$opts = {game_id => 1, date => 2, season => [3] };
$query = build_date_query($opts);
is_deeply($query, {game_id => {'$in' => [1]}}, 'game_id query built');
delete $opts->{game_id};
$query = build_date_query($opts);
is_deeply($query, {date => {'$in' => [2]}}, 'date query built');
delete $opts->{date};
$query = build_date_query($opts);
is_deeply($query, {season => {'$in' => [3]}}, 'season option query built');
delete $opts->{season};
eval { $query = build_date_query($opts) };
like($@, qr/^Error: no date field present/, "no date caught");
$opts->{start_season} = 1926;
$opts->{stop_season} = 1929;
$query = build_date_query($opts);
is_deeply($query, {season => {'$in' => [1926 .. 1929]}}, 'stop/start season query built');
is(Sport::Analytics::NHL::DB::get_default_id_field('STOP'), 'event_id', 'default id of event ok');
is(Sport::Analytics::NHL::DB::get_default_id_field('penalty'), 'penalty_id', 'default id of non-plural ok');
is(Sport::Analytics::NHL::DB::get_default_id_field('games'), 'game_id', 'default id of plural ok');