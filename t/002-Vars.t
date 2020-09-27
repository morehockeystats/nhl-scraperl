#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More;

use Sport::Analytics::NHL::Vars qw(:all);

plan tests => 15 + $IS_AUTHOR*1;

ok(defined $CURRENT_SEASON, 'current season defined');
ok(defined $CURRENT_STAGE,  'current stage defined');

ok(defined $DEFAULT_PLAYERFILE_EXPIRATION, 'playerfile expiration defined');
ok(defined $DEFAULT_MONGO_DB, 'default mongo db has a name');
ok(defined $DEFAULT_SQL_DB, 'default sql db has a name');
ok(defined $DEFAULT_STORAGE, 'default storage set');

ok(defined $DATA_DIR, 'data directory defined');
ok(defined $REPORTS_DIR, 'reports directory defined');
ok(defined $LOG_DIR, 'log directory defined');
ok(defined $MAIL_DIR, 'mail directory defined');
ok(defined $DATA_DIR, 'data directory defined');

ok(defined $SCHEDULE_FILE, 'schedule file defined');

ok(defined $IS_AUTHOR, 'author or not defined');
is_deeply($CONFIG, {}, 'config is not yet filled');
ok(defined $CONFIG_FILE, 'default config file defined');
ok($CONFIG_FILE eq './hockeydb.conf', 'and set to a local location') if $IS_AUTHOR;