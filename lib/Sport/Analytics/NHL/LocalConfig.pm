package Sport::Analytics::NHL::LocalConfig;

use strict;
use warnings FATAL => 'all';
use v5.10;

use parent 'Exporter::Tiny';

=head1 NAME

Sport::Analytics::NHL::LocalConfig - local configuration settings

=head1 SYNOPSYS

Local configuration settings

Provides local settings such as the location of the Mongo DB or the data storage, and the current season/stage setting.

This list shall expand as the release grows.

    use Sport::Analytics::NHL::LocalConfig;
    print "The data is stored in $LOCAL_CONFIG{DATA_DIR}\n";

=cut

our %LOCAL_CONFIG = (
	CURRENT_SEASON                => 2019,
	CURRENT_STAGE                 => 3,
	IS_AUTHOR                     => $ENV{HOCKEYDB_AUTHOR} || 0,
	BASE_DIR                      => '/hockey2',
	SCHEDULE_FILE                 => 'schedule.json',
	DEFAULT_PLAYERFILE_EXPIRATION => 1,
	DEFAULT_MONGO_DB              => 'hockey2020',
	DEFAULT_SQL_DB                => 'hockey2020',
	DEFAULT_STORAGE               => 'mongo',
	FS_BACKUP                     => 1,
	MONGO_HOST                    => '127.0.0.1',
	MONGO_PORT                    => 27017,
	CONFIG_FILE                   => 'hockeydb.conf',
);

$LOCAL_CONFIG{CONFIG_FILE} = (
	$LOCAL_CONFIG{IS_AUTHOR} ? './' : '/etc/'
) . "$LOCAL_CONFIG{CONFIG_FILE}";

$LOCAL_CONFIG{uc . '_DIR'} = $LOCAL_CONFIG{BASE_DIR} . "/$_"
	for qw(reports data log mail);

our @EXPORT = qw(%LOCAL_CONFIG);

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::LocalConfig>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::LocalConfig


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::LocalConfig>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::LocalConfig>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::LocalConfig>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::LocalConfig>

=back

