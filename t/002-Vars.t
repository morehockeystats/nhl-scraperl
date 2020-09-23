#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More;

plan tests => 13;

use Sport::Analytics::NHL::Vars qw(:all);

ok(defined $CURRENT_SEASON, 'current season defined');
ok(defined $CURRENT_STAGE,  'current stage defined');

ok(defined $DEFAULT_PLAYERFILE_EXPIRATION, 'playerfile expiration defined');
ok(defined $DEFAULT_MONGO_DB, 'default mongo db has a name');
ok(defined $DEFAULT_SQL_DB, 'default sql db has a name');
ok(defined $DEFAULT_STORAGE, 'default storage set');

ok(defined $DATA_DIR, 'data directory defined');
ok(defined $REPORTS_DIR, 'reports directory defined');
ok(defined $LOGS_DIR, 'log directory defined');
ok(defined $MAIL_DIR, 'mail directory defined');
ok(defined $DATA_DIR, 'data directory defined');

ok(defined $SCHEDULE_FILE, 'schedule file defined');

ok(defined $IS_AUTHOR, 'author or not defined');
