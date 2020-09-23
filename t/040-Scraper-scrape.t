#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use t::lib::Util;
test_env();

use Test::More;

use Sport::Analytics::NHL::Scraper qw(scrape);

plan tests => 5;

eval {scrape({})};
like($@, qr/^Can't scrape without a URL/, 'Expected error without URL');
$ENV{HOCKEYDB_NONET} = 1;
my $result = scrape({url => 'https://google.com'});
is($result, undef, 'No network, no result');
$ENV{HOCKEYDB_NONET} = 0;
eval { scrape({url => 'https://sdfsdffsd.fsdfsdf..fsdfsfqwerf', retries => 1, die => 1}) };
like($@, qr/^Failed to retrieve/, 'Expected error invalid URL');
eval { $result = scrape({url => 'https://google.com', retries => 1, validate => sub { 0 }}) };
is($result, undef, 'validation sub intercepted');
$result = scrape({url => 'https://google.com', retries => 1 });
ok(length($result), 'we scraped something!');
