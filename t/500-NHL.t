#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

no strict 'refs';

use Test::More;

use Sport::Analytics::NHL;
plan tests => scalar(@Sport::Analytics::NHL::EXPORT) + 1;
for my $sub (@Sport::Analytics::NHL::EXPORT) {
	ok(defined &$sub, "sub $sub defined");
}
is(Sport::Analytics::NHL::_version(), $Sport::Analytics::NHL::VERSION, "reasonable version");
