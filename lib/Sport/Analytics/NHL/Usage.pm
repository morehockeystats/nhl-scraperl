package Sport::Analytics::NHL::Usage;

use strict;
use warnings FATAL => 'all';
use v5.10;

use Getopt::Long qw(:config no_ignore_case bundling);
use List::MoreUtils qw(arrayify);
use Date::Format;

use Sport::Analytics::NHL qw(_version);
use Sport::Analytics::NHL::Vars   qw(:local_config $CONFIG);
use Sport::Analytics::NHL::Config qw(:basic :seasons);
use Sport::Analytics::NHL::Util   qw(read_config);

use parent 'Exporter::Tiny';

our @EXPORT = qw(gopts usage);

=head1 NAME

Sport::Analytics::NHL::Usage - an internal utility module standardizing the usage of our applications.

=head1 FUNCTIONS

=over 2

=item C<convert_opt>

A small routine converting the CLI option with dashes into a snake-case string

 Arguments: the option text

 Returns: the converted string

=item C<usage>

Produces a usage message and exits

 Arguments: [optional] exit status, defaults to 0

 Returns: exits

=item C<gopts>

This is the main wrapper for GetOptions to keep things coherent.

 Arguments: usage message
            arrayref of options, by tags or specific opts
            arrayref of arguments
 [optional] arrayref of explicitly excluded options

 Returns: a list of options to which convert_opt() was applied.
 Don't ask me why.

=item C<parse_config_opts>

Parses the config-file specified either via the option, or the $ENV{HOCKEYDB_CONFIG} environment variable or
the $CONFIG_FILE variable in LocalConfig.pm . Only attempts to parse the file if present and readable. Reads
it into $CONFIG global variable.

 Arguments: options hashref, already parsed by bulk of gopts()
 Returns: void ($CONFIG is set)

=item C<order_date_opts>

Sorts out a variety of date opts

 Arguments: specified options
            type (date/season/week)
 [optional] whether these are single or start/stop points

 Returns: void. Modifies the opts hash inline.

=item C<parse_date_opts>

Produces a start and end range of season, dates, or weeks

 Arguments: specified options
 [optional] forced start value
 [optional] forced stop value

 Returns: the range between the start and the stop option,
          default applies.

=back

=cut

our $USAGE_MESSAGE = '';
our $def_db  = $ENV{HOCKEYDB_DBNAME}  || $DEFAULT_MONGO_DB || 'hockey';
our $def_sql = $ENV{HOCKEYDB_SQLNAME} || $DEFAULT_SQL_DB   || 'hockey';
our $VERSION = $Sport::Analytics::NHL::VERSION;
our %OPTS = (
	standard  => [
		{
			short       => 'h', long => 'help',
			action      => sub {usage();},
			description => 'print this message and exit'
		},
		{
			short       => 'V', long => 'version',
			action      => sub {
				say _version();
				exit;
			},
			description => 'print version and exit'
		},
		{
			short       => 'v', long => 'verbose',
			action      => sub {$ENV{HOCKEYDB_VERBOSE} = 1},
			description => 'produce verbose output to STDERR'
		},
		{
			short       => 'd', long => 'debug',
			action      => sub {$ENV{HOCKEYDB_DEBUG} = 1;},
			description => 'produce debug output to STDERR'
		},
		{
			long        => 'config-file', type => 's', arg => 'CONFIG',
			description => 'Use config file CONFIG',
		},
		{
			long        => 'dry-run', short => 'n',
			action      => sub {$ENV{HOCKEYDB_DRYRUN} = 1;},
			description => 'Execute a dry run (no updates or posts)',
		},
	],
	season    => [
		{
			short       => 's', long => 'start-season', arg => 'SEASON', type => 'i',
			description => "Start at season SEASON (default $CURRENT_SEASON)",
		},
		{
			long        => 'season', arg => 'SEASON', type => 'i', repeatable => 1,
			description => "Operate on SEASON (repeatable) (default $CURRENT_SEASON)",
		},
		{
			short       => 'S', long => 'stop-season', arg => 'SEASON', type => 'i',
			description => "Stop at season SEASON (default $CURRENT_SEASON)",
		},
		{
			short       => 'T', long => 'stage', arg => 'STAGE', type => 'i',
			description => "Operate stage STAGE ($REGULAR: REGULAR, $PLAYOFF: PLAYOFF, default: $CURRENT_STAGE",
		},
	],
	date      => [
		{
			long        => 'start-date', arg => 'YYYYDDMM', type => 'i',
			description => "Start at date date",
		},
		{
			long        => 'date', arg => 'YYYYDDMM|today|yesterday', type => 'i', repeatable => 1,
			description => "Operate on date",
		},
		{
			long => 'stop-date', arg => 'YYYYDDMM', type => 'i',
			description => "Stop at date date",
		},
	],
	week      => [
		{
			short       => 'w', long => 'start-week', arg => 'WEEK', type => 'i',
			description => "Start at week WEEK",
		},
		{
			long        => 'week', arg => 'WEEK', type => 'i', repeatable => 1,
			description => "Operate on WEEK",
		},
		{
			short       => 'W', long => 'stop-week', arg => 'WEEK', type => 'i',
			description => "Stop at week WEEK",
		},
	],
	game      => [
		{
			short       => 'w', long => 'start-game-id', arg => 'GAMEID', type => 'i',
			description => "Start at game GAMEID",
		},
		{
			long        => 'game-id', arg => 'GAMEID', type => 'i', repeatable => 1,
			description => "Operate on game GAMEID",
		},
		{
			short       => 'W', long => 'stop-game-id', arg => 'GAMEID', type => 'i',
			description => "Stop at game GAMEID",
		},
	],
	feature   => [
		{
			long        => 'disable', arg => 'FEATURE', type => 's@',
			description => 'disable feature FEATURE',
		},
		{
			long        => 'enable', arg => 'FEATURE', type => 's@',
			description => 'enable feature FEATURE',
		},
	],
	database  => [
		{
			long        => 'no-database',
			description => 'Do not use a MongoDB backend',
			action      => sub { $ENV{HOCKEYDB_NODB} = 1 },
		},
		{
			short       => 'D', long => 'database', arg => 'DB', type => 's',
			description => "Use Mongo database DB (default $def_db)",
		},
	],
	compile   => [
		{
			long        => 'no-compile',
			description => 'Do not compile file even if storable is absent',
		},
		{
			long        => 'recompile',
			description => 'Compile file even if storable is present',
		}
	],
	merge     => [
		{
			long        => 'no-merge',
			description => 'Do not merge file even if storable is absent',
		},
		{
			long        => 'remerge',
			description => 'Compile file even if storable is present',
		}
	],
	normalize => [
		{
			long        => 'no-normalize',
			description => 'Do not normalize file even if storable is absent',
		},
		{
			long        => 'renormalize',
			description => 'Compile file even if storable is present',
		},
	],
	poller    => [
		{
			long        => 'pid-file', arg => 'PID_FILE', short => 'P',
			description => 'Use pid-file PID_FILE',
		},
		{
			long        => 'no-pid',
			description => 'Do not use a pid file',
		},
		{
			long        => 'test-mode',
			description => 'Run in test mode (implies dry-run and force)',
		},
		{
			long        => 'once',
			description => 'Only run once and exit',
		},
	],
	generator => [
		{
			long        => 'all',
			description => 'generate everything',
		},
		{
			long        => 'pulled-goalie',
			description => 'generate pulled goalies',
		},
		{
			long        => 'ne-goals',
			description => 'generate goals scored while with empty net',
		},
		{
			long        => 'icings-info',
			description => 'generate icings information',
		},
		{
			long        => 'fighting-majors',
			description => 'generate implicit fighting majors',
		},
		{
			long        => 'strikebacks',
			description => 'generate strikebacks',
		},
		{
			long        => 'lead-changing-goals',
			description => 'generate lead changing goals',
		},
		{
			long        => 'icecount-mark',
			description => 'generate icecount marks',
		},
		{
			long        => 'challenges',
			description => 'generate challenges',
		},
		{
			long        => 'leading-trailing',
			description => 'generate leading/trailing records',
		},
		{
			long        => 'offsides_info',
			description => 'generate offsides',
		},
		{
			long        => 'gamedays',
			description => 'generates breaks in days before this game',
		},
		{
			long        => 'common-games',
			description => 'generate common games',
		},
		{
			long        => 'clutch-goals',
			description => 'generate clutch goals',
		},
		{
			long        => 'penalty-browser',
			description => 'generate penalty browser files',
		},
		{
			long        => 'score',
			description => 'generate event scores',
		},
		{
			long        => 'corsi',
			description => 'generate advanced stats: corsi, fenwick, shots',
		},
	],
	twitter   => [
		{
			long        => 'bgcolor', arg => 'COLOR',
			description => 'Background color for the tweet',
		},
		{
			long        => 'fgcolor', arg => 'COLOR',
			description => 'Foreground color for the tweet',
		},
		{
			long        => 'show-text',
			description => 'Show the text before converting it to image',
		},
		{
			long        => 'file', short => 'F', arg => 'FILE',
			description => 'Read text from file FILE',
		},
		{
			long        => 'tab-file', short => 'T',
			description => 'Indicate the file is TAB-Separated',
		},
		{
			long        => 'header', short => 'H', arg => 'HEADER',
			description => 'Provide header HEADER to the tweet',
		},
	],
	fantasy   => [
		{
			long        => 'commit-level', short => 'L', arg => 'N', type => 'i',
			description => 'Commit rating calculations after N games',
		},
		{
			long        => 'average', short => 'a', arg => 'FLOAT', type => 's',
			description => 'Set average scoring to FLOAT',
		},
		{
			long        => 'spread', short => 's', arg => 'FLOAT', type => 's',
			description => 'Set scoring spread to FLOAT',
		},
		{
			long        => 'formula', arg => 'STRING', type => 's',
			description => 'Name of the preset formula to use'
		},
		{
			long        => 'history', arg => 'NUM', type => 'i',
			description => 'Number of years to go back for training',
		},
		{
			long        => 'format', arg => 'TYPE', type => 's',
			description => 'Output format: html|txt|csv',
		},
		{
			long        => 'nickname', arg => 'NICK', type => 's',
			description => 'nickname',
		},
		{
			long        => 'count', arg => 'NUM', type => 'i',
			description => 'Entries count per position (default 100)',
		},
		{
			long        => 'daily',
			description => "Operate on daily fantasy - today's opponent",
		},
	],
	model     => [
		{
			long        => 'concept', arg => 'TYPE', type => 's',
			description => 'Use concept TYPE',
		},
		{
			long        => 'model', arg => 'TYPE', type => 's',
			description => 'Use model TYPE',
		},
		{
			long        => 'init',
			description => 'initialize ratings for the model',
		},
		{
			long        => 'generate',
			description => 'generate rating datepoints',
		},
		{
			long        => 'predict',
			description => 'generate predictions with the model',
		},
		{
			long        => 'home-factor', arg => 'FLOAT', type => 's',
			description => 'specify the home advantage factor',
		},
		{
			long        => 'playoff-factor', arg => 'FLOAT', type => 's',
			description => 'specify the PO home advantage factor',
		},
		{
			long        => 'goalie', arg => 'GoalieID', type => 'i',
			description => 'force GoalieID on the roster'
		},
		{
			long        => 'type', arg => 'MODEL-TYPE', type => 's',
			description => 'use this MODEL-TYPE (model option)',
		},
		{
			long        => 'standings',
			description => 'predict standings',
		},
		{
			long        => 'playoffs',
			description => 'predict playoffs',
		},
		{
			long        => 'bet',
			description => 'bet against money lines',
		},
		{
			long        => 'future',
			description => 'predict only future games',
		},
		{
			long        => 'use-status',
			description => 'Use player health status for selection of roster',
		},
		{
			long        => 'date', arg => 'DATE', type => 'i',
			description => 'Only run for date DATE'
		},
	],
	penalties => [
		{
			long        => 'no-set-strengths',
			description => 'Do not set strengths',
		},
		{
			long        => 'no-analyze',
			description => 'Do not analyze penalties, just set strengths',
		},
		{
			long        => 'clear',
			description => 'Clear the analysis data instead',
		},
	],
	publish   => [
		{
			long        => 'update', short => 'U',
			description => 'Only update data',
		},
		{
			long        => 'no-prepare', short => 'N',
			description => 'Skip the preparation step',
		},
		{
			long        => 'prepare-only', short => 'n',
			description => 'Only do the preparation step',
		},
		{
			long        => 'no-output', short => 'O',
			description => 'Skip the web pages generation step',
		},
		{
			long        => 'output-only', short => 'o',
			description => 'Only do the web pages generation step',
		},
		{
			long        => 'no-page', short => 'P', type => 's', arg => 'PAGE',
			description => 'Skip page PAGE (section-page)',
		},
		{
			long        => 'page', short => 'p', type => 's', arg => 'PAGE',
			description => 'Only work on page PAGE (section-page)',
		},
		{
			long        => 'no-section', short => 'S', type => 's', arg => 'SECTION',
			description => 'Skip section SECTION',
		},
		{
			long        => 'section', short => 's', type => 's', arg => 'SECTION',
			description => 'Only work on section SECTION',
		},
		{
			long        => 'domain', type => 's', arg => 'DOMAIN',
			description => 'Only work on domain DOMAIN'
		},
		{
			long        => 'no-domain', type => 's', arg => 'DOMAIN',
			description => 'Skip domain DOMAIN'
		},
		{
			long        => 'snippet-only',
			description => 'Only work on snippets',
		},
		{
			long        => 'list', short => 'l',
			description => 'List available pages and exit',
		},
		{
			long        => 'sitemap', short => 'x',
			description => "Generate sitemaps",
		},
		{
			long        => 'recreate-table',
			description => 'Force SQL table recreation',
		},
	],
	misc      => [
		{
			long        => 'invert',
			description => 'Invert data, i.e. use shot against, goal against etc.'
		},
		{
			long        => 'event-type', type => 's', arg => 'EVENT_TYPE',
			description => 'Specify the type of event to work upon',
		},
		{
			long        => 'duration', type => 'i', arg => 'NUM',
			description => 'Specify duration to work with',
		},
		{
			long        => 'threshold', type => 'i', arg => 'NUM',
			description => 'Specify threshold to work with',
		},
		{
			short       => 'f', long => 'force',
			description => 'override/overwrite existing data',
		},
		{
			long        => 'gamecount', type => 'i', arg => 'NUM',
			description => 'only run for NUM of games from the start of the season',
		},
		{
			short       => 'q', long => 'sql',
			description => "use SQL database DBNAME (default $def_sql)",
			arg         => 'DBNAME', type => 's',
		},
		{
			long        => 'generate-sql',
			description => "Produce relevant sql tables",
		},
		{
			long        => 'end',
			description => "Generate the data for the end of the season",
		},
		{
			long        => 'test',
			description => 'Test the validity of the files (use with caution)'
		},
		{
			long        => 'doc',
			description => 'Only process reports of type doc (repeatable). Available types are: BS, PL, RO, GS, ES',
			repeatable  => 1, arg => 'DOC',
			type        => 's'
		},
		{
			long        => 'no-schedule-crawl',
			description => 'Try to use schedule already present in the system',
		},
		{
			long        => 'no-parse',
			description => 'Do not parse the scraped files',
		},
		{
			long        => 'rating', arg => 'NUM', type => 'i', optional => 1,
			description => 'Use Elo ratings in calculations',
		},
		{
			long        => 'train-span', arg => 'NUM', type => 'i',
			description => 'Train the model over NUM YEARS',
		},
		#{
		#	long        => 'twitter-dir', arg => 'DIR',
		#	description => "Use directory DIR for storing images instead of $TWITTER_DIR",
		#},
		{
			short       => 'E', long => 'data-dir', arg => 'DIR', type => 's',
			description => "Data directory root (default $DATA_DIR)",
		},
		{
			long        => 'break', arg => 'N', type => 'i',
			description => 'only use games after a break of size N',
		},
	],
	yahoo     => [
		{
			long        => 'all',
			description => 'Query all players',
		},
	],
	poe       => [
		{
			long        => 'poe', arg => 'STAGE', type => 's@',
			description => 'Run the stages STAGE (repeatable, any of pre, wheel, post)',
		},
	],
);

sub usage (;$) {

	my $status = shift || 0;

	print join("\n", <<ENDUSAGE =~ /^\t\t(.*)$/gm), "\n";
$USAGE_MESSAGE
ENDUSAGE
	exit $status;
}

sub convert_opt ($) {

	my $opt = shift;

	my $c_opt = $opt;
	$c_opt =~ s/\-/_/g;
	$c_opt;
}

sub parse_config_opts (;$) {

	my $opts = shift || {};

	$opts->{config_file} ||= (
		$ENV{HOCKEYDB_CONFIG_FILE} || $CONFIG_FILE
	);
	$CONFIG = read_config($opts->{config_file}) if $opts->{config_file} && -r $opts->{config_file};
}

sub gopts ($$$;$) {

	my $wid  = shift;
	my $opts = shift;
	my $args = shift;
	my $ipts = shift || [];

	my %g_opts = ();
	my $u_opts = {};
	my $u_arg = @{$args} ? ' Arguments' : '';
	my $usage_message ="
\t\t$wid
\t\tUsage: $0 [Options]$u_arg
";
	unshift(@{$opts}, ':standard') unless grep {$_ eq '-standard'} @{$opts};
	if (@{$opts}) {
		$usage_message .= "\t\tOptions:\n";
		for my $opt_group (@{ $opts }) {
			my @opts;
			if ($opt_group =~ /^\:(.*)/) {
				@opts = @{ $OPTS{$1} };
			}
			else {
				@opts = grep { $_->{long} eq $opt_group } arrayify values %OPTS;
			}
			for my $ipt (@{$ipts}) {
				@opts = grep { $_->{long} ne $ipt } @opts;
			}
			for my $opt (@opts) {
				$usage_message .= sprintf(
					"\t\t\t%-20s %-10s %s\n",
					($opt->{short} ? "-$opt->{short}|" : '') . "--$opt->{long}",
					$opt->{arg} || '',
					$opt->{description},
				);
				my $is_repeatable = $opt->{repeatable} ? '@' : '';
				my $optional = $opt->{optional} ? ':' : '=';
				$g_opts{
					(($opt->{short} ? "$opt->{short}|" : '') . $opt->{long}) .
						($opt->{type} ? "$optional$opt->{type}$is_repeatable" : '')
				} = ($opt->{action} || \$u_opts->{convert_opt($opt->{long})});
			}
		}
	}
	else {
		$usage_message .= "\t\tNo Options\n";
	}
	if (@{$args}) {
		$usage_message .= "\t\tArguments:\n";
		for my $arg (@{$args}) {
			$usage_message .= sprintf(
				"\t\t\t%-20s %s%s",
				$arg->{name}, $arg->{description},
				$arg->{optional} ? ' [optional]' : ''
			) . "\n";
		}
	}
	$USAGE_MESSAGE = $usage_message;
	GetOptions(%g_opts) || usage();
	$u_opts->{dry_run} = $ENV{HOCKEYDB_DRYRUN} if defined $ENV{HOCKEYDB_DRYRUN};
	parse_date_opts($u_opts);
	parse_config_opts($u_opts);
	$u_opts;
}

sub order_date_opts ($$;$) {

	my $opts = shift;
	my $type = shift;
	my $start_stop = shift || 0;

	if ($start_stop) {
		if ($type eq 'date') {
			for my $s (qw(start stop)) {
				$opts->{$s . '_date'} = time2str("%Y%m%d", time - 86400)
					if $opts->{$s . '_date'}  eq 'yesterday';
				$opts->{$s . '_date'} = time2str("%Y%m%d", time)
					if $opts->{$s . '_date'} eq 'today';
			}
		}
		$opts->{$type} = [$opts->{"start_$type"} .. $opts->{"stop_$type"}];
	}
	else {
		if ($type eq 'date') {
			for my $o (@{$opts->{$type}}) {
				$o = time2str("%Y%m%d", time - 86400) if $o eq 'yesterday';
				$o = time2str("%Y%m%d", time)         if $o eq 'today';
			}
		}
		$opts->{$type} = [sort @{$opts->{$type}}];
	}
}

sub parse_date_opts ($;$$) {

	my $opts        = shift;
	my $start_value = shift;
	my $stop_value  = shift;

	my $found = 0;
	for (qw(game_id date season week)) {
		if ($found) {
			delete $opts->{$_};
			next;
		}
		if ($opts->{$_}) {
			$opts->{$_} = [$opts->{$_}] unless ref $opts->{$_};
			order_date_opts($opts, $_);
			$found = 1;
		}
		elsif ($opts->{"start_$_"} || $opts->{"stop_$_"}) {
			$start_value ||= $opts->{"start_$_"};
			$stop_value  ||= $opts->{"stop_$_"};
			if ($_ eq 'week') {
				$start_value ||= 1;
				$stop_value  ||= 24;
			}
			elsif ($_ eq 'season') {
				$start_value ||= $FIRST_SEASON;
				$stop_value  ||= $CURRENT_SEASON;
			}
			elsif ($_ eq 'date') {
				$stop_value  ||= time2str("%Y%m%d", time);
			}
			die "Start or stop values are unavailable for option $_"
				if !$start_value || !$stop_value;
			$opts->{"start_$_"} ||= $start_value;
			$opts->{"stop_$_"}  ||= $stop_value;
			order_date_opts($opts, $_, 1);
			delete $opts->{"start_$_"};
			delete $opts->{"stop_$_"};
			$found = 1;
		}
	}
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Usage>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Usage


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Usage>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Usage>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Usage>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Usage>

=back
