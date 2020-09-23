#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Schedule;
plan tests => 2;

my $schedule = Sport::Analytics::NHL::Schedule->new();
isa_ok($schedule, 'Sport::Analytics::NHL::Schedule');
isa_ok($schedule->{config}, 'HASH', 'opts HASH defined');