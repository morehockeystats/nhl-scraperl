#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Game;
plan tests => 10;

eval {Sport::Analytics::NHL::Game->new()};
is($@, "Can't initialize a game object without id\n", "dies without an id");
eval {Sport::Analytics::NHL::Game->new(1234)};
is($@, "Invalid game id 1234 specified (not SSSSTTNNNN)\n", "dies with a bad id");
my $game = Sport::Analytics::NHL::Game->new(2019020001);
isa_ok($game, 'Sport::Analytics::NHL::Game');
isa_ok($game->{config}, 'HASH', 'opts HASH defined');
is_deeply($game->{data}, {game_id => 2019020001, season => 2019, stage => 2, season_id => 1}, 'id parsed correctly');
is($game->{config}{id_field}, 'game', 'id field set');
$game = Sport::Analytics::NHL::Game->new({game_id => 2019020001});
isa_ok($game, 'Sport::Analytics::NHL::Game');
isa_ok($game->{config}, 'HASH', 'opts HASH defined');
is_deeply($game->{data}, {game_id => 2019020001, season => 2019, stage => 2, season_id => 1}, 'id parsed correctly');
is($game->{config}{id_field}, 'game', 'id field set');

