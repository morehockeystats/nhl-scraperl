#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Vars qw($DEFAULT_STORAGE $DEFAULT_MONGO_DB $DB);
use Sport::Analytics::NHL::DB;

if ($ENV{HOCKEYDB_NODB} || $DEFAULT_STORAGE ne 'mongo' ) {
	plan skip_all => 'Mongo not defined';
	exit;
}
plan tests => 9;

my $db = Sport::Analytics::NHL::DB->new();
isa_ok($db, 'Sport::Analytics::NHL::DB');
isa_ok($db->{dbh}, 'MongoDB::Database');
isa_ok($db->{client}, 'MongoDB::MongoClient');
is($ENV{HOCKEYDB_DBNAME}, $DEFAULT_MONGO_DB, 'mongo db name set');
is_deeply($DB, $db, 'global var $DB set');

$db = Sport::Analytics::NHL::DB->new({MONGO_DB => 'hockeytest'});
isa_ok($db, 'Sport::Analytics::NHL::DB');
isa_ok($db->{dbh}, 'MongoDB::Database');
isa_ok($db->{client}, 'MongoDB::MongoClient');
is($ENV{HOCKEYDB_DBNAME}, 'hockeytest', 'custom mongo db name set');
