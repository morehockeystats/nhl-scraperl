#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Vars qw($REPORTS_DIR);

use Sport::Analytics::NHL::Game;
plan tests => 5;

my $game = Sport::Analytics::NHL::Game->new(2019020001);
is($game->get_path(), "/hockey2/reports/2019/0002/0001", 'default path correct');
$REPORTS_DIR = "/zz";

is($game->get_path(), "/zz/2019/0002/0001", 'custom path correct');

my $doc_urls;
$doc_urls = $game->set_doc_urls();
is_deeply([sort keys %{$doc_urls}], [qw(BS ES GS PL RO TH TV)], 'modern reports, all docs accounted');
$game->{data}{season} = 1918;
$doc_urls = $game->set_doc_urls();
is_deeply([sort keys %{$doc_urls}], [qw(BS)], 'antique reports, one doc accounted');
$game->{data}{season} = 2000;
$doc_urls = $game->set_doc_urls();
is_deeply([sort keys %{$doc_urls}], [qw(BS ES GS)], 'midway reports, some docs accounted');
