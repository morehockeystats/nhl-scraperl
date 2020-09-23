#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL;
plan tests => scalar(@Sport::Analytics::NHL::EXPORT);
for my $sub (@Sport::Analytics::NHL::EXPORT) {
	ok(defined &$sub, "sub $sub defined");
}
