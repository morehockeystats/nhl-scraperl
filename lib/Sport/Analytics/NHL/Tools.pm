package Sport::Analytics::NHL::Tools;

use strict;
use warnings FATAL => 'all';
use v5.10;

use Sport::Analytics::NHL::Util qw(debug);
use Sport::Analytics::NHL::Config qw(:seasons :league);
use Sport::Analytics::NHL::Vars qw($CACHES);

use parent 'Exporter::Tiny';

=head1 NAME

Sport::Analytics::NHL::Tools - Commonly used routines that are system-dependent
(i.e. make sense only for this package).

=head1 SYNOPSIS

Commonly used routines that are specific to the Sport::Analytics::NHL ecosystem. For the independent stuff see Sport::Analytics::NHL::Util .

  use Sport::Analytics::NHL::Tools qw(resolve);
  my $team = resolve_team('NY Rangers'); # returns NYR
  #and so on

By default nothing is exported. You can import the functions either by name, or by the tags listed below, or by tag ':all'.

dates: get_start_stop_date

db: resolve_team

=head1 FUNCTIONS

=over 2

=item C<get_start_stop_date>

Gets the earliest possible start and latest possible end for a season in format YYYY-MM-DD

 Arguments: the season
 Returns: (YYYY-09-02,YYYY+1-09-01) (unless it's 2019)

=item C<_resolve_team>

If the cache has missed, actually resolve the team requested in C<resolve_team>

=item C<resolve_team>

Attempts to resolve the name of a team to the normalized 3-letter id. Uses cached resolving when possible.

 Arguments: the name of a team,
 Returns: the 3-letter normalized id

=back

=cut

our @dates = qw(get_start_stop_date);
our @db    = qw(resolve_team);

our @EXPORT_OK = (@dates, @db);
our %EXPORT_TAGS = (
	all   => \@EXPORT_OK,
	dates => \@dates,
	db    => \@db,
);

sub get_start_stop_date ($) {

	my $season = shift;

	my $start_month = $season == $DELAYED_START ? 11 : 9;
	my $stop_month  = $season == $DELAYED_STOP  ? 10 : 8;
	# Temp hack due to a bug in the NHL website.
	my $start_day = $season == 2016 ? 30 : 1;
	(
		sprintf("%04d-%02d-%02d", $season+0, $start_month, $start_day),
		sprintf("%04d-%02d-%02d", $season+1, $stop_month,  30),
	);
}

sub _resolve_team ($) {

	my $team = shift;
	return 'MTL' if $team =~ /MONTR.*CAN/i || $team =~ /CAN.*MONTR/i;
	return 'NHL' if uc($team) eq 'LEAGUE'  || $team eq 'NHL';
	return $team if $TEAMS{$team};
	for my $team_id (keys %TEAMS) {
		return $team_id if $team_id eq $team;
		for my $type (qw(short long full)) {
			return $team_id if grep { uc($_) eq uc($team) } @{$TEAMS{$team_id}->{$type}};
		}
	}
	die "Couldn't resolve team $team";
}

sub resolve_team ($) {

	my $team = shift;

	$CACHES->{teams}{names}{$team} ||= _resolve_team($team);
	$CACHES->{teams}{names}{$team};
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Tools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Tools


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Tools>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Tools>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Tools>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Tools>

=back
