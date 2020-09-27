#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;
use t::lib::Util;
test_env();

use Sport::Analytics::NHL::Vars qw($CACHES $DB $DEFAULT_STORAGE $IS_AUTHOR);
use Sport::Analytics::NHL::DB;
use Sport::Analytics::NHL::Util qw(:debug);

if ($ENV{HOCKEYDB_NODB} || $DEFAULT_STORAGE ne 'mongo') {
	plan skip_all => 'Mongo not defined';
	exit;
}
plan tests => 4;
$ENV{HOCKEYDB_DEBUG} = $IS_AUTHOR;
$DB = Sport::Analytics::NHL::DB->new();
$DB->insert('test_data', {x => 1});
my $insert = $DB->pick('test_data');
is($insert->{x}, 1, 'element retrieved');
ok($insert->{_id}, '_id assigned');
$DB->get_collection('test_data')->drop();
$DB->insert('test_data', {test_data_id => 1, x => 1});
$DB->insert('test_data', {test_data_id => 1, x => 2}, {force => 1});
$insert = $DB->pick('test_data');
is($insert->{test_data_id}, 1, 'element retrieved');
is($insert->{x}, 2, 'and it is overwritten');

END {
    if ($DB) {
        $DB->get_collection('test_data')->drop();
    }
}