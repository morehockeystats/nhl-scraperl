#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Tools qw(:dates);

plan tests => 3;

my $ssd;
$ssd = [get_start_stop_date(2018)];
is_deeply($ssd, [qw(2018-09-01 2019-08-30)], 'start date ok');
$ssd = [get_start_stop_date(2019)];
is_deeply($ssd, [qw(2019-09-01 2020-10-30)], 'delayed stop date ok');
$ssd = [get_start_stop_date(2020)];
is_deeply($ssd, [qw(2020-11-01 2021-08-30)], 'delayed start date ok');
