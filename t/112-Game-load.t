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
my $data = dclone $game->{data};

my $path = $game->get_path();
is($path, 't/data/2019/0002/0001');
$game->load_from_fs();
is_deeply($data, $game->{data}, 'no file, data unchanged');
$game->load_from_db();
is_deeply($data, $game->{data}, 'no db item, data unchanged');
$game->load();
is_deeply($data, $game->{data}, 'nothing, data unchanged');
