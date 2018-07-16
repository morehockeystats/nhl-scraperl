#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More;

use JSON;

use Sport::Analytics::NHL::LocalConfig;
use Sport::Analytics::NHL::Config;
use Sport::Analytics::NHL::Test;
use Sport::Analytics::NHL::Util;
use Sport::Analytics::NHL::Tools;
use Sport::Analytics::NHL;

use t::lib::Util;

plan qw(no_plan);

test_env();
$ENV{HOCKEYDB_DATA_DIR} = 't/tmp/data';
system(qw(mkdir -p t/tmp/));
system(qw(cp -a t/data t/tmp/));
$ENV{HOCKEYDB_NODB} = 1;
#use Data::Dumper;
#print Dumper \%ENV;
#exit;
my $nhl = Sport::Analytics::NHL->new();
my @storables = $nhl->compile({}, 201120010);
is_deeply(
	[ sort @storables ],
	[qw(
		t/tmp/data/2011/0002/0010/BH.storable
		t/tmp/data/2011/0002/0010/BS.storable
		t/tmp/data/2011/0002/0010/ES.storable
		t/tmp/data/2011/0002/0010/GS.storable
		t/tmp/data/2011/0002/0010/PL.storable
		t/tmp/data/2011/0002/0010/RO.storable
	)],
);
for my $storable (@storables) {
	ok(-f $storable, 'file exists');
}
END {
	system(qw(rm -rf t/tmp/data));
}
