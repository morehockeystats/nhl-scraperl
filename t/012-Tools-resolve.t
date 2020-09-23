#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';

use Test::More;

use Sport::Analytics::NHL::Tools qw(:db);
use Sport::Analytics::NHL::Vars  qw($CACHES);

plan tests => 17;

is(Sport::Analytics::NHL::Tools::_resolve_team('MTL'), 'MTL', 'direct resolve by id');
is($CACHES->{teams}, undef, "cache not set in direct resolve");
eval { resolve_team('XXX') };
like($@, qr/^Couldn't resolve team XXX/, 'exception caught');
is(resolve_team('MTL'), 'MTL', 'resolve by id');
is($CACHES->{teams}{names}{MTL}, 'MTL', 'cache set');
is(resolve_team('league'), 'NHL', 'NHL resolved');
is(resolve_team('Canadien Montreal'), 'MTL', 'frenchies resolved');
is(resolve_team('Carolina Hurricanes'), 'CAR', 'full name resolved');
is(resolve_team('Hartford Whalers'), 'CAR', 'previous full name resolved');
is(resolve_team('HFD'), 'CAR', 'previous ID resolved');
is(resolve_team('Whalers'), 'CAR', 'previous long name resolved');
is(resolve_team('Black Hawks'), 'CHI', 'previous long alias resolved');
is(resolve_team('Vegas'), 'VGK', 'location resolved');
is(resolve_team('MINS'), 'DAL', 'previous 4-letter code resolved');
is(resolve_team('Pittsburgh Pirates'), 'PIR', 'defunct team resolved');
is(resolve_team('VMI'), 'VMA', 'PCHA team resolved');
is(scalar(keys %{$CACHES->{teams}{names}}), 13, 'all thirteen values stored in cache');
