#!perl

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use Test::More;
use t::lib::Util;

test_env();

use Sport::Analytics::NHL::Util qw(:all);
use Sport::Analytics::NHL::Vars qw($LOG_DIR $IS_AUTHOR);

plan tests => 11;

my $string = 'x';

my $tmp_file = '/tmp/mhs-test';
ok(write_file($string, $tmp_file), 'file written');
is(-s $tmp_file, length($string), 'file written correctly');

my $x = read_file($tmp_file);
is($x, $string, 'file read back correctly');
my $config = q{
ab	cd
#ef gh
};
write_file($config, $tmp_file);
my $conf = read_config($tmp_file);
is_deeply($conf, {ab=>'cd'}, 'config file read correctly');
my $tabs = q{
ab	cd	ef
};
write_file($tabs, $tmp_file);
is_deeply(read_tab_file($tmp_file), [[qw(ab cd ef)]], 'tab file read correctly');
unlink $tmp_file;
is_deeply(merge_hashes({},{}), {}, 'two empty hashes make one empty hash');
is_deeply(merge_hashes({},{a => 1}), {a => 1}, 'an empty hash makes other one');
is_deeply(merge_hashes({a => 1},{}), {a => 1}, 'no matter the order');
is_deeply(merge_hashes({a => 1},{b => 2}), {a => 1, b => 2}, 'two hashes combined');
is_deeply(merge_hashes({a => 1, c => 1},{a => 2, b => 2}), {a => 2, b => 2, c => 1}, 'override correct');

my $fn = log_mhs('abcd', 'message', $IS_AUTHOR ? 'debug' : 'error');
is(-s $fn, 49, 'filename written correctly');
unlink $fn;
END {
    unlink glob "$LOG_DIR/*"
}
