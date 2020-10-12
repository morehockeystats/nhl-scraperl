use v5.10.1;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
	module_name        => 'Sport::Analytics::NHL',
	license            => 'gnu',
	dist_author        => q{More Hockey Stats <contact@morehockeystats.com>},
	dist_version_from  => 'lib/Sport/Analytics/NHL.pm',
	dist_abstract      => 'Interface to the National Hockey League data',
	release_status     => 'stable',
	configure_requires => {
		'Module::Build' => '0',
	},
	build_requires     => {
		'Test::More' => '0',
	},
	requires           => {
		'Data::Dumper'      => 2.124,
		'Date::Parse'       => 2.31,
		'Date::Format'      => 2.24,
		'experimental'      => 0.019,
		'File::Basename'    => 2.77,
		'File::Path'        => 2.08,
		'Getopt::Long'      => 2.38,
		'JSON'              => 2.15,
		'List::MoreUtils'   => 0.423,
		'LWP::Simple'       => 5.827,
		'LWP::Protocol::https' => 5.827,
		'parent'            => 0.1,
		'POSIX'             => 1.17,
		'Storable'          => 2.21,
		'Syntax::Collector' => 0.005,
		'Time::HiRes'       => 1.9721,
	},
	recommends         => {
		'MongoDB'   => 'v1.6.0',
		'BSON::OID' => 'v1.8.1',
	},
	add_to_cleanup     => [ 'Sport-Analytics-NHL-*' ],
	script_files       => {
		'scripts/crawl-schedule' => 'blib/scripts/crawl-schedule',
		'scripts/crawl-games'    => 'blib/scripts/crawl-games',
	},
);

$builder->create_build_script();
