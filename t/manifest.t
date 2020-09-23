#!perl 

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

my $min_tcm = 0.9;
eval "use Test::CheckManifest $min_tcm";
plan skip_all => "Test::CheckManifest $min_tcm required" if $@;

ok_manifest({
	filter => [
		qr/\.svn/, 
		qr/\.gz/, 
		qr/\~$/, 
		qr/storable$/, 
		qr/normalized.json/a,
		qr/.tree$/,
		qr/ignore.txt/,
		qr/_Deparsed_XSubs.pm/,
	], 
	exclude => [
		'/doc/ideas.txt',
		'/tools',
		'/_build',
		'/blog',
		'/fantasy',
		'/yahoo',
		'/twitter',
		'/ncaa',
		'/html',
		'/doc',
		'/t/template',
		'/.idea',
	],
	bool => 'or'
});
