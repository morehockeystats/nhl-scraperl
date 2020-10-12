package Sport::Analytics::NHL::Game;

use strict;
use warnings FATAL => 'all';
use v5.10.1;

use Storable qw (store retrieve dclone);

use Sport::Analytics::NHL::Vars    qw(
	$DEFAULT_STORAGE $DB $CURRENT_SEASON $REPORTS_DIR $FS_BACKUP
	$GAME_STORABLE
);
use Sport::Analytics::NHL::Util    qw(:debug :file :strings);
use Sport::Analytics::NHL::Config  qw(:seasons);
use Sport::Analytics::NHL::DB;

=head1 NAME

Sport::Analytics::NHL::Game - NHL Game implementation - crawl, store, retrieve

=head1 SYNOPSYS

NHL Game implementation. The implementation is completely OO. Nothing is exported.

	use Sport::Analytics::NHL::Game;
	my $game = Sport::Analytics::NHL::Game->new($opts);
	$game->crawl($opts);
	# No parsing YET!

=head1 METHODS

=over 2

=item new()

Constructor. Creates a game object - without data yet, but with a
configuration which can be passed as an argument in a hashref. The extra
key field of schedule collection is going to be game_id, so the id_field
is defaulted to 'game'. In addition $game->{data} initialized with the
principal game data derived from the game id: the season, the stage and
the season Id.

The game id (SSSSTTNNNN NHL format) must be passed as one of the
configuration arguments.

=item get_path()

Deduces the storage path to the game in the report archive, the
$REPORT_DIR/SSSS/TTTT/NNNN path.

 Arguments: None. Game Id obtained from the game object.
 Returns: The root/SSSS/TTTT/NNNN path.

=item load_from_fs()

Loads the data field of the object from the $GAME_STORABLE file
(default: game.storable) if such a file is present.

=item load_from_db()

Loads the data field of the object from the Mongo Database storage
referenced by the game_id field in the game config.

=item load(;$opts)

Loads the data into the games's "data" field, arbitrating between
C<load_from_db> and C<load_from_fs>

=item save_scrape($doc, $format, $content)

Saves the scraped $content for report of type $doc in format $format.
The file is root/SSSS/TTTT/NNNN/DOC.format . The file is not parsed or
modified.

 Arguments: the report type (e.g. PL, RO, BS ...)
            the format (html, json, text)
            the scraped content
 Returns:   the result of the file write

=item set_doc_urls(;$game_id)

Sets the URLs for the documents related to the given game ID, accounting
for the debut year of each document type. By default the game ID is taken
from $self->{config} but may be provided explicitly.

=item populate($doc, $scrape, $opts)

Brokers the correct population method for the doc given the content.
Saves the scraped data. no_parse option in the opts hashref disallows
parsing.

 Arguments: the report type (e.g. PL, RO, BS ...)
            the scraped content
            the invocation options hashref
 Returns:   the result of the save of the scraped doc.

=item crawl($opts)

Actually executes the crawl.

 Arguments: the options for the crawl and the population
 Returns:   void. Files are saved and object's data field is populated.

=back

=cut

use Sport::Analytics::NHL::Scraper qw(scrape);

our $HTML_REPORT_URL = 'http://www.nhl.com/scores/htmlreports/%d%d/%s%02d%04d.HTM';
our $LIVE_REPORT_URL = 'https://statsapi.web.nhl.com/api/v1/game/%s/feed/live';

sub new ($;$) {

	my $class = shift;
	my $opts  = shift || {};

	$opts = {game_id => $opts} unless ref $opts;
	die "Can't initialize a game object without id\n" if ! $opts->{game_id};
	die "Invalid game id $opts->{game_id} specified (not SSSSTTNNNN)\n" if $opts->{game_id} !~ /^\d{10}$/;
	my $self = {config => $opts, data => {game_id => $opts->{game_id}}};
	$self->{data}{season}    = substr($opts->{game_id}, 0, 4)+0;
	$self->{data}{stage}     = substr($opts->{game_id}, 4, 2)+0;
	$self->{data}{season_id} = substr($opts->{game_id}, 6,10)+0;
	$self->{config}{id_field} ||= 'game';
	bless $self, $class;
	$self;
}

sub get_path ($) {

	my $self = shift;

	my $root = $self->{config}{data_dir}
		? $self->{config}{data_dir} . "/reports"
		: $REPORTS_DIR;
	join(
		'/',
		$root,
		map(sprintf('%04s', $_), ($self->{data}{season}, $self->{data}{stage}, $self->{data}{season_id}))
	);
}

sub load_from_fs ($) {

	my $self = shift;

	my $game_path = $self->get_path();
	$self->{data} = retrieve "$game_path/$GAME_STORABLE" if -f "$game_path/$GAME_STORABLE";
}

sub load_from_db ($) {

	my $self = shift;

	$DB ||= Sport::Analytics::NHL::DB->new();
	my $query = { ($self->{config}{id_field} . '_id') => $self->{config}{$self->{config}{id_field} . '_id'} };
	my $data = $DB->pick('games', $query);
	$self->{data} = $data if $data;
}

sub load ($;$) {

	my $self = shift;

	$DEFAULT_STORAGE eq 'mongo'
		? $self->load_from_db(@_)
		: $self->load_from_fs()
}

sub set_doc_urls ($;$) {

	my $self    = shift;
	my $game_id = shift || $self->{config}{game_id};

	my $season    = $self->{data}{season};
	my $stage     = $self->{data}{stage};
	my $season_id = $self->{data}{season_id};
	my $urls = {};
	for my $doc (keys %FIRST_REPORT_SEASONS) {
		if ($doc eq 'BS') {
			$urls->{$doc} = sprintf($LIVE_REPORT_URL, $game_id);
		}
		elsif ($season >= $FIRST_REPORT_SEASONS{$doc}) {
			$urls->{$doc} = sprintf(
				$HTML_REPORT_URL, $season, $season+1, $doc, $stage, $season_id
			);
		}
	}
	$urls;
}

sub save_scrape ($$$$) {

	my $self    = shift;
	my $doc     = shift;
	my $format  = shift;
	my $content = shift;

	my $report_file = sprintf(
		'%s/%s.%s', $self->get_path(),
		$doc, $format,
	);
	write_file($content, $report_file);
}

sub populate ($$$$) {

	my $self   = shift;
	my $doc    = shift;
	my $scrape = shift;
	my $opts   = shift;

	my $format = get_magic($scrape);
	if (! $opts->{no_parse}) {
		my $method = "populate_$format";
		$self->$method($doc, $scrape);
	}
	$self->save_scrape($doc, $format, $scrape) unless $opts->{no_save} or $self->{config}{no_save};
}

sub crawl ($;$) {

	my $self = shift;
	my $opts = shift;

	$opts->{game_id} ||= $self->{config}{game_id};
	my $_opts = dclone $opts;
	$_opts->{urls} ||= $self->set_doc_urls($opts->{game_id});
	verbose "Crawling $opts->{game_id}";
	for my $doc (keys %{$_opts->{urls}}) {
		$_opts->{url} = $_opts->{urls}{$doc};
		# $_opts->{die} = 1;
		my $scraped_doc = scrape($_opts);
		next unless $scraped_doc;
		$self->populate($doc, $scraped_doc, $_opts);
	}
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Game>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Game


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Game>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Game>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Game>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Game>

=back

