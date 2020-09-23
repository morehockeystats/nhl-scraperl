#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Tools qw(:all);

plan tests => scalar(@Sport::Analytics::NHL::Tools::EXPORT_OK);
for my $sub (@Sport::Analytics::NHL::Tools::EXPORT_OK) {
	ok(defined &$sub, "sub $sub defined");
}
