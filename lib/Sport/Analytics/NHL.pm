package Sport::Analytics::NHL;

use strict;
use warnings FATAL => 'all';
use v5.10.1;

use Sport::Analytics::NHL::Schedule;

=head1 NAME

Sport::Analytics::NHL - Crawl data from NHL.com and put it into a database.

=head1 VERSION

Version 2.01

=cut

our $VERSION = '2.01';

=head1 SYNOPSIS

Crawl data from NHL.com and put it into a database.

Crawls the NHL.com website, processes the game reports and stores them into a Mongo database or into the filesystem.
Version 2 is a complete rewrite. The releases starting with 2.00 will have more and more features. This one is
laying a foundation and thus only has schedule crawling/storing capability.

    use Sport::Analytics::NHL qw(get_schedule);

    get_schedule({season => 2020});
    ...
    # more functionality to be added in later releases.

=head1 EXPORT

get_schedule() - get the schedule for the given season/date (span)

=cut

=head1 METHODS

=over 2

=item get_schedule($)

Gets the schedule by the specified options hash (season, season span, date, date span, optional force overwrite).
See L<Sport::Analytics::NHL::Usage> for more information.

=back

=cut

use parent 'Exporter::Tiny';

our @EXPORT = qw(get_schedule _version);

sub _version () { return $VERSION }
sub get_schedule ($) {

	my $opts = shift;

	my $schedule = Sport::Analytics::NHL::Schedule->new($opts);
	$schedule->crawl($opts) if $opts->{force};
	$schedule->crawl($opts) if (
		! $schedule->{data} or ! @{$schedule->{data}}
	) && ! $opts->{force};
	$schedule->save() unless $ENV{HOCKEYDB_DRYRUN};
	$schedule->{data};
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL>

=back

