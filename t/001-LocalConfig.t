#!perl

use strict;
use warnings FATAL => 'all';

use Test::More;

plan tests => 1;

use Sport::Analytics::NHL::LocalConfig;

isa_ok(\%LOCAL_CONFIG, 'HASH', 'Local config defined');
