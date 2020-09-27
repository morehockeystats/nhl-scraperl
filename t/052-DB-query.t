#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;
use t::lib::Util;
test_env();
use Sport::Analytics::NHL::Vars qw($CACHES $DEFAULT_STORAGE $IS_AUTHOR $CONFIG $CONFIG_FILE);
use Sport::Analytics::NHL::DB;
use Sport::Analytics::NHL::Util qw(:debug read_config);

if ($ENV{HOCKEYDB_NODB} || $DEFAULT_STORAGE ne 'mongo') {
	plan skip_all => 'Mongo not defined';
	exit;
}
plan tests => 4;
$ENV{HOCKEYDB_DEBUG} = $IS_AUTHOR;
my $db = Sport::Analytics::NHL::DB->new();
my $result = $db->query('find', 'schedule', {ab => 1});
isa_ok($result, 'MongoDB::Cursor', 'cursor returned');
my @result = $db->query('find', 'schedule', {ab => 1}, {all => 1});
is(scalar(@result), 0, 'empty result all');
$result = $db->find('schedule', {ab => 1});
isa_ok($result, 'MongoDB::Cursor', 'cursor returned for find');
$result = $db->pick('schedule', {ab => 1});
is($result, undef, 'item returned for pick');
