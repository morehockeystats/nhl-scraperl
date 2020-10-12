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
plan tests => 4;

my $game = Sport::Analytics::NHL::Game->new(2019020001);
my $doc = 'ZZ';
my $format = 'zzzz';

my $file = $game->save_scrape($doc, $format, 'abcd');
is($file, 't/data/2019/0002/0001/ZZ.zzzz', 'saved name correct');
is(-s $file, 4, 'saved file correct');
unlink $file;
$file = $game->populate($doc, 'abcd', {no_parse => 1});
is($file, 't/data/2019/0002/0001/ZZ.text', 'saved name correct');
is(-s $file, 4, 'saved file correct');
unlink $file;
