#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;
use Storable qw(store retrieve dclone);
use Sport::Analytics::NHL::Vars qw($REPORTS_DIR $DEFAULT_STORAGE);

use t::lib::Util;
test_env();

use Sport::Analytics::NHL::Game;
plan tests => 2;

my $game = Sport::Analytics::NHL::Game->new(1917020001);
$game->crawl({no_parse => 1});
my $file = 't/data/1917/0002/0001/BS.json';
ok(-f $file, 'file crawled');
ok(-s $file > 1000, 'some contents are present');
unlink $file;
