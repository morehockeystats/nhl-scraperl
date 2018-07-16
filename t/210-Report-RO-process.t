#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More tests => 3;
use Sport::Analytics::NHL::LocalConfig;

$ENV{HOCKEYDB_DEBUG} = $IS_AUTHOR;
use Sport::Analytics::NHL::Report::RO;
use Sport::Analytics::NHL::Config;
use Sport::Analytics::NHL::Util;
use Sport::Analytics::NHL::Test;

my $report;
$report = Sport::Analytics::NHL::Report::RO->new({
	file => 't/data/2011/0002/0010/RO.html',
});
#$BOXSCORE = $report;
isa_ok($report, 'Sport::Analytics::NHL::Report::RO');
$report->process();
test_boxscore($report, {ro => 1});
is($TEST_COUNTER->{Curr_Test}, 183, 'full test run');
is($TEST_COUNTER->{Curr_Test}, $TEST_COUNTER->{Test_Results}[0], 'all ok');
$BOXSCORE = undef;

