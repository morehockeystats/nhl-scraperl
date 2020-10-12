#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use t::lib::Util;
test_env();

use Test::More;

use Sport::Analytics::NHL::Scraper qw(validate_json);

plan tests => 4;

my $json = '{"x": 1}';
is(validate_json($json), 1, "validate correct json ok");
is(validate_json($json, 1), 1, "validate correct json non-fatal anyways");
my $bad_json = '{"x": 1';
is(validate_json($bad_json), 0, "validate incorrect json emits warning");
eval {validate_json($bad_json, 1)};
like($@, qr/expected.*offset/, "validate incorrect json may be fatal");
