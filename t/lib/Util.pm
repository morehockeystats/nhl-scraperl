package t::lib::Util;

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use POSIX qw(strftime);

use Sport::Analytics::NHL::Config qw(:all);
use Sport::Analytics::NHL::Vars qw($IS_AUTHOR $REPORTS_DIR);
use Sport::Analytics::NHL::Util;

use Storable qw(dclone store retrieve);

use Data::Dumper;

use parent 'Exporter';

our @EXPORT = qw(
    test_env summarize_tests
);

my $TEST_DB = 'hockeytest';

sub test_env (;$) {

	my $dbname = shift || $TEST_DB;

	$ENV{HOCKEYDB_DBNAME}   = $dbname;
	$ENV{HOCKEYDB_DEBUG}    = $IS_AUTHOR;
	$ENV{HOCKEYDB_DATA_DIR} = $REPORTS_DIR = 't/data';
	$ENV{HOCKEYDB_TEST}     = 1;
	$ENV{HOCKEYDB_SQLNAME}  = 'hockeytest';
}

1;
