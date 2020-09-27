package Sport::Analytics::NHL::Vars;

use strict;
use warnings;
use v5.10;

use parent 'Exporter::Tiny';

use Sport::Analytics::NHL::LocalConfig;

our $FS_BACKUP;

our @local_config_variables = qw(
	CURRENT_SEASON CURRENT_STAGE
	DEFAULT_PLAYERFILE_EXPIRATION DEFAULT_STORAGE FS_BACKUP
	DEFAULT_MONGO_DB MONGO_HOST MONGO_PORT
	DEFAULT_SQL_DB
	BASE_DIR DATA_DIR LOG_DIR REPORTS_DIR MAIL_DIR
	IS_AUTHOR
	SCHEDULE_FILE CONFIG_FILE
);
my @LOCAL_CONFIG = ();
my @DIRS = ();
no strict 'refs';
for my $lcv (@local_config_variables) {
	my $var = '$'.$lcv;
	eval qq{our $var; $var= "$LOCAL_CONFIG{$lcv}";};
	next unless defined $var;
	push(@LOCAL_CONFIG, $var);
	push(@DIRS, $var) if $var =~ /dir$/i;
}
$FS_BACKUP ||= 0;
our $CONFIG = {};
our @GLOBALS = qw($DB $CACHES $SQL $CONFIG);
#our @WEB    = qw($WEB_STAGES $WEB_STAGES_TOTAL @SEASON_START_STOP $WEB_LOG $ERROR_WEB_LOG);
our @BASIC   = qw($CURRENT_SEASON $CURRENT_STAGE);
our @SCRAPE  = (@BASIC, @DIRS, qw($DEFAULT_PLAYERFILE_EXPIRATION));
our @TEST    = (@BASIC, qw($IS_AUTHOR));

our @EXPORT_OK = (qw(
	@local_config_variables
), @LOCAL_CONFIG, @SCRAPE, @BASIC, @TEST, @GLOBALS);
our %EXPORT_TAGS = (
	local_config => [ @LOCAL_CONFIG, qw(@local_config_variables) ],
	scrape       => \@SCRAPE,
	test         => \@TEST,
	all          => \@EXPORT_OK,
	basic        => \@BASIC,
	dirs         => \@DIRS,
	globals      => \@GLOBALS,
);

1;

=head1 NAME

Sport::Analytics::NHL::Vars - Global variables for a variety of use.

=head1 SYNOPSYS

This module maintains and exports the global variables and the variables defined in Sport::Analytics::NHL::LocalConfig

    use Sport::Analytics::NHL::Vars;

    $CACHES = {};

Only variables are defined in this module, and they can be accessed by tags:

=over 2

=item :local_config

LocalConfig.pm variables

=item :globals

$DB, $SQL - Mongo and MySQL handles, $CACHES - global caching system

=item :basic

$CURRENT_SEASON, $CURRENT_STAGE

=item :scrape

:basic, $DEFAULT_PLAYERFILE_EXPIRATION - when the playerfile json is considered stale and needs to be re-scraped

=item :test

:basic, $IS_AUTHOR - you shouldn't set this one to 1 unless you know what you're doing.

=item :mongo

$DEFAULT_MONGO_DB, $MONGO_HOST, $MONGO_PORT

=item :all

All of the above

=back

=cut

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Vars>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Vars


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Vars>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Vars>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Vars>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Vars>

=back
