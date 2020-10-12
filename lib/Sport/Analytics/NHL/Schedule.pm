package Sport::Analytics::NHL::Schedule;

use strict;
use warnings FATAL => 'all';
use v5.10.1;

use JSON;
use List::MoreUtils qw(part);
use Date::Parse;

use Sport::Analytics::NHL::Vars    qw($DEFAULT_STORAGE $DB $CURRENT_SEASON $REPORTS_DIR $SCHEDULE_FILE $FS_BACKUP);
use Sport::Analytics::NHL::Config  qw(:seasons :basic);
use Sport::Analytics::NHL::Util    qw(:debug :file :time);

=head1 NAME

Sport::Analytics::NHL::Schedule - NHL Schedule implementation - crawl, store, retrieve

=head1 SYNOPSYS

NHL Schedule implementation. The implementation is completely OO. Nothing is exported.

	use Sport::Analytics::NHL::Schedule;
	my $schedule = Sport::Analytics::NHL::Schedule->new($opts);
	$schedule->crawl($opts);
	$schedule->save() unless $ENV{HOCKEYDB_DRYRUN};
	$schedule->{data};

=head1 METHODS

=over 2

=item new()

Constructor. Creates a Schedule object - without data yet, but with a configuration which
can be passed as an argument in a hashref. The extra key field of schedule collection is
going to be game_id, so the id_field of the configuration is defaulted to 'game'.

=item load_from_db(;$opts)

Loads the data from the Mongo database returning it as a list.

=item load_from_fs()

Loads the data from the filesystem ($REPORTS_DIR/$season/$SCHEDULE_FILE) returing it as a list.
Only retrieval by season is supported.

=item load(;$opts)

Loads the data into the schedule's "data" field, arbitrating between
C<load_from_db> and C<load_from_fs>

=item save_to_db()

Saves $schedule->{data} into the MongoDB.

=item save_to_fs()

Saves $schedule->{data} into the filesystem ($REPORT_DIR/$season/schedule.json). Only
saving by season.

=item save(;$discard)

Saves $schedule->{data} arbitrating between C<save_to_db> and C<save_to_fs>.
Discards $self->{data} if the optional flag is specified.

=item process_scheduled_game($game)

Processes a raw game as mapped from schedule json entry, computing and deriving extra fields.
Everything is changed within the $game, nothing to return.

=item populate_scheduled_game($schedule_game, $date)

Populates a game entry from an entry in the NHL schedule json.
Calls C<process_scheduled_game> to populate the extra fields and adds the game to $self->{data}

=item populate($schedule_json)

Populates an NHL schedule json into $self->{data}

=item crawl_by_date(;$date)

Crawls NHL schedule by date - either explicitly specified, or pre-specified during construction in
$self->{config}{date}

=item crawl_by_season(;$season)

Crawls NHL schedule by season - either explicitly specified, or pre-specified during construction in
$self->{config}{season}

=item crawl(;$opts)

Crawls the NHL schedule by season or by date - depending on the configuration or the optional date parameter
passed.

=back

=cut

use Sport::Analytics::NHL::Scraper qw(scrape validate_json);
use Sport::Analytics::NHL::Tools   qw(:dates resolve_team);
use Sport::Analytics::NHL::DB;

our $SCHEDULE_JSON_API  = 'https://statsapi.web.nhl.com/api/v1/schedule?startDate=%s&endDate=%s';

sub new ($;$) {

	my $class = shift;
	my $opts  = shift || {};

	my $self = {config => $opts, data => []};
	$self->{config}{id_field} ||= 'game_id';
	bless $self, $class;
	$self;
}

sub load_from_db ($;$) {

	my $self = shift;
	my $opts = shift;

	$DB ||= Sport::Analytics::NHL::DB->new();
	my $query = build_date_query($self->{config}, $opts);
	my @games = $DB->find('schedule', $query, {
		sort => { date => 1 },
		all  => 1,
	});
	@games;
}

sub load_from_fs ($) {

	my $self = shift;

	if (! $self->{config}{season}) {
		verbose "Retrieving games from FS is supported only by season\n";
		return ();
	}
	$self->{config}{season} = [$self->{config}{season}]
		unless ref $self->{config}{season};
	my @games = ();
	for my $season (@{$self->{config}{season}}) {
		my $schedule_file = "$REPORTS_DIR/$season/$SCHEDULE_FILE";
		if (! -r $schedule_file) {
			print "No readable schedule file $schedule_file, skipping\n";
			next;
		}
		my $schedule_json = read_file($schedule_file);
		push(@games, @{decode_json($schedule_json)});
	}
	@games;
}

sub load ($;$) {

	my $self = shift;

	$self->{data}  = [ $DEFAULT_STORAGE eq 'mongo'
		? $self->load_from_db(@_)
		: $self->load_from_fs()
	];
}

sub save_to_db ($) {

	my $self = shift;

	$DB ||= Sport::Analytics::NHL::DB->new();

	my $res = $DB->insert('schedule', $self->{data}, $self->{config});
	$self->save_to_fs if $self->{config}{season} && $FS_BACKUP;
	$res ? 0 : 1;
}

sub save_to_fs ($) {

	my $self = shift;

	if (! $self->{config}{season}) {
		verbose "Saving games to FS is supported only by season\n";
		return 1;
	}
	my @season_schedules = part { $_->{season} - 1917 } @{$self->{data}};
	for my $season_schedule (@season_schedules) {
		next if ! $season_schedule or ! $season_schedule->[0];
		my $json = encode_json($season_schedule);
		my $season = $season_schedule->[0]{season};
		my $schedule_file = "$REPORTS_DIR/$season/$SCHEDULE_FILE";
		write_file($json, $schedule_file);
	}
	0;
}

sub save ($;$) {

	my $self    = shift;
	my $discard = shift || 0;

	$DEFAULT_STORAGE eq 'mongo'
		? $self->save_to_db()
		: $self->save_to_fs();

	$self->{data} = [] if $discard;
}

sub process_scheduled_game ($) {

	my $game = shift;

	$game->{stage}     = substr($game->{game_id}, 4, 2) + 0;
	return if $game->{stage} != $REGULAR and $game->{stage} != $PLAYOFF;
	$game->{season}    = substr($game->{game_id}, 0, 4) + 0;
	$game->{date}      =~ s/\D//g;
	$game->{ts}        = str2time($game->{ts});
	$game->{year}      = int($game->{date} / 10000);
	$game->{season_id} = $game->{game_id} % 10000;
	$game->{$_}        = resolve_team($game->{$_}) for qw(away home);
}

sub populate_scheduled_game ($$$) {

	my $self          = shift;
	my $schedule_game = shift;
	my $date          = shift;

	my $game = {
		game_id => $schedule_game->{gamePk},
		feed    => $schedule_game->{link},
		date    => $date,
		ts      => $schedule_game->{gameDate},
		away    => $schedule_game->{teams}{away}{team}{name},
		home    => $schedule_game->{teams}{home}{team}{name},
		status  => $schedule_game->{status}{abstractGameState},
	};
	process_scheduled_game($game);
	push(@{$self->{data}}, $game) if $game->{stage} == $REGULAR || $game->{stage} == $PLAYOFF;

}

sub populate ($$) {

	my $self = shift;
	my $schedule_json = shift;

	my $schedule = decode_json($schedule_json);
	for my $schedule_date (@{$schedule->{dates}}) {
		for my $schedule_game (@{$schedule_date->{games}}) {
			$self->populate_scheduled_game($schedule_game, $schedule_date->{date});
		}
	}
}

sub crawl_by_date ($;$) {

	my $self = shift;
	my $date = shift || $self->{config}{date};

	substr($date, 6, 0) = '-';
	substr($date, 4, 0) = '-';
	my $url = sprintf($SCHEDULE_JSON_API, $date, $date);
	my $schedule_json = scrape({
		url => $url, die => 1, validate => sub { validate_json(shift, 1) }
	});
	$self->populate($schedule_json);
}

sub crawl_by_season ($;$) {

	my $self = shift;
	my $season = shift || $self->{config}{season};
	my $schedule_json;
	my @seasons = $season
		? (ref $season ? @{$season} : $season)
		: (($self->{config}{start_season} || $FIRST_SEASON)
		.. ($self->{config}{stop_season} || $CURRENT_SEASON));
	@seasons = @{$seasons[0]} if ref $seasons[0];
	for my $season (@seasons) {
		next if grep { $_ == $season } @LOCKOUT_SEASONS;
		my ($start_date, $stop_date) = get_start_stop_date($season);
		my $schedule_json_url = sprintf(
			$SCHEDULE_JSON_API, $start_date, $stop_date
		);
		$schedule_json = scrape({ url => $schedule_json_url, die => 1 });
		$self->populate($schedule_json) if $schedule_json;
	}
}

sub crawl ($;$) {

	my $self = shift;
	my $opts = shift;

	($self->{config}{date} || $opts->{date})
		? $self->crawl_by_date()
		: $self->crawl_by_season();
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Schedule>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Schedule


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Schedule>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Schedule>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Schedule>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Schedule>

=back

