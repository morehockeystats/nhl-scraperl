#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More tests => 3;

use Sport::Analytics::NHL::Report::PL;
use Sport::Analytics::NHL::Config;
use Sport::Analytics::NHL::Util;
my $report;
$report = Sport::Analytics::NHL::Report::PL->new({
	file => 't/data/2011/0002/0010/PL.html',
});
isa_ok($report, 'Sport::Analytics::NHL::Report::PL');
like($report->{source}, qr'html', 'html file in source');
ok(-f 't/data/2011/0002/0010/PL.tree', 'tree file created');

