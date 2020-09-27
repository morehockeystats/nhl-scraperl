package Sport::Analytics::NHL::Scraper;

use strict;
use warnings FATAL => 'all';
use v5.10.1;

use LWP::Simple;
use Time::HiRes qw(usleep);

use Sport::Analytics::NHL::Tools qw(:dates);
use Sport::Analytics::NHL::Util  qw(:debug log_mhs);

use parent 'Exporter::Tiny';

=head1 NAME

Sport::Analytics::NHL::Scraper - Scrape and crawl the NHL website for data

=head1 SYNOPSIS

Scrape and crawl the NHL website for data

  use Sport::Analytics::NHL::Scraper qw(scrape)
  my $content = scrape({url => http://www.nhl.com, retries => 2});

=head1 FUNCTIONS

=over 2

=item C<scrape>

A wrapper around the LWP::Simple::get() call for retrying and control.

Arguments: hash reference containing

  * url => URL to access
  * retries => Number of retries
  * validate => sub reference to validate the download
  * die => whether to die upon failure

Returns: the content if both download and validation are successful undef otherwise.

=back

=cut

our @EXPORT_OK = qw(scrape);

our $DEFAULT_RETRIES = 3;

sub scrape ($) {

	my $opts = shift;
	die "Can't scrape without a URL" unless defined $opts->{url};

	if ($ENV{HOCKEYDB_NONET}) {
		print "No network access defined, aborting\n";
		return undef;
	}
	$opts->{retries}  ||= $DEFAULT_RETRIES;
	$opts->{validate} ||= sub { 1 };

	my $begin_tx = time;
	my $r = 0;
	my $content;
	while (! $content && $opts->{retries} > $r++) {
		debug "Trying ($r/$opts->{retries}) $opts->{url}...";
		log_mhs('Scraper', "Trying ($r/$opts->{retries}) $opts->{url}...", 'debug');
		$content = get($opts->{url});
		unless ($opts->{validate}->($content)) {
			verbose "$opts->{url} failed validation, retrying";
			log_mhs('Scraper', sprintf("Failed to validate %s", $opts->{url}), 'notice');
			$content = undef;
		}
		usleep 200000 unless $content;
	}
	if (! $content) {
		log_mhs('Scraper', sprintf("Failed to retrieve %s", $opts->{url}), 'error');
		die "Failed to retrieve $opts->{url}" if $opts->{die};
	}
	else {
		my $now = time;
		debug sprintf("Retrieved in %.3f seconds", $now - $begin_tx) if $content;
		log_mhs('Scraper', sprintf("Retrieved %s in %.3f seconds", $opts->{url}, $now - $begin_tx), 'notice');
	}
	$content;
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Scraper>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Scraper


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Scraper>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Scraper>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Scraper>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Scraper>

=back
