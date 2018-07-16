package Sport::Analytics::NHL::Test;

use v5.10.1;
use strict;
use warnings FATAL => 'all';
use experimental qw(smartmatch);

use parent 'Exporter';

use Carp;
use Data::Dumper;
use Storable;

use List::MoreUtils qw(uniq);

use Sport::Analytics::NHL::Config;
use Sport::Analytics::NHL::LocalConfig;
use Sport::Analytics::NHL::Util;
use Sport::Analytics::NHL::Errors;

=head1 NAME

Sport::Analytics::NHL::Test - Utilities to test NHL reports data.

=head1 SYNOPSYS

Utilities to test NHL report data

 These are utilities that test and validate the data contained in the NHL reports to detect errors. They are also used to test and validate the permutations that are performed by this software on the data.
 Ideally, that method should extend Test::More, but first, I was too lazy to figure out how to do it, and second, I notice that in the huge number of tests that are run, Test::More begins to drag things down.

    use Sport::Analytics::NHL::Test;
    test_team_id('SJS') # pass
    test_team_id('S.J') # fail and die (usually)

 The failures are usually bad enough to force the death of the program and an update to Sport::Analytics::NHL::Errors (q.v.), but see the next section

=head1 GLOBAL VARIABLES

 The behaviour of the tests is controlled by several global variables:
 * $TEST_COUNTER - contains the number of the current test in Curr_Test field and the number of passes/fails in Test_Results.
 * $DO_NOT_DIE - when set to 1, failed test will not die.
 * $MESSAGE - the latest failure message
 * $TEST_ERRORS - accumulation of errors by type (event, player, boxscore, team)

=head1 FUNCTIONS

=over 2

=item C<my_die>

Either dies with a stack trace dump, or aggregates the error messages, based on $DO_NOT_DIE
 Arguments: the death message
 Returns: void

=item C<my_test>

Executes a test subroutine and sets the failure message in case of failure. Updates test counters.
 Arguments: the test subroutine and its arguments
 Returns: void

=item C<my_like>

Approximately the same as Test::More::like()

=item C<my_is>

Approximately the same as Test::More::is()

=item C<my_ok>

Approximately the same as Test::More::ok()

=item C<my_is_one_of>

Approximately the same as grep {$_[0] == $_} $_[1]

=item C<test_season>

For the test_* functions below the second argument is always the notification message. Sometimes third parameter may be passed. This one tests if the season is one between $FIRST_SEASON (from Sports::Analytics::NHL::Config) and $CURRENT_SEASON (from Sports::Analytics::NHL::LocalConfig)

=item C<test_stage>

Tests if the stage is either Regular (2) or Playoff (3)

=item C<test_season_id>

Tests the season Id to be between 1 and 1500 (supposedly maximum number of games per reg. season)

=item C<test_game_id>

Tests the game Id to be of the SSSSTIIII form. In case optional parameter is_nhl, tests for the NHL id SSSSTTIIII

=item C<test_team_code>

Tests if the string is a three-letter team code, not necessarily the normalized one.

=item C<test_team_id>

Tests if the string is a three-letter franchise code, as specified in keys of Sports::Analytics::NHL::Config::TEAMS

=item C<test_ts>

Tests the timestamp to be an integer (negative for pre-1970 games) number.

=item C<test_game_date>

Tests the game date to be in YYYYMMDD format.

=item C<is_noplay_event>

Check if the event is not a played one (PEND, GEND, PSTR, STOP)

=item C<is_unapplicable>

Check if the particular stat is measured in season being processed, stored in $THIS_SEASON

=item C<set_tested_stats>

Set the stats tested for a player

=item C<test_assists_and_servedby>

Tests the correct values in assists and servedby fields

=item C<test_boxscore>

Overall sequence to test the entire boxscore

=item C<test_coords>

Tests the event coordinates

=item C<test_decision>

Tests the decision for the goaltender being one of W,L,O,T

=item C<test_event>

Overall sequence to test the event

=item C<test_event_by_type>

Route the particular event testing according to its type

=item C<test_event_coords>

Checks the applicability of coordinates for the event and tests them

=item C<test_event_description>

Tests the event's description (for existence, actually)

=item C<test_event_strength>

Checks the applicability of strength setting for the event and tests it

=item C<test_events>

Test the boxscore's events (loops over test_event (q.v.))

=item C<test_goal>

Tests the goal event

=item C<test_header>

Tests the header information of the boxscore

=item C<test_name>

Tests the player's name (to have a space between two words, more or less)

=item C<test_officials>

Tests the officials definition in the boxscore

=item C<test_penalty>

Tests the penalty event

=item C<test_periods>

Tests the periods' reports from the boxscore

=item C<test_player>

Tests a player entry in the team's roster

=item C<test_player1>

Tests valid population of the player1 event field

=item C<test_player2>

Tests valid population of the player2 event field

=item C<test_player_id>

Tests the player id to be the valid 7-digit one one starting with 8

=item C<test_position>

Tests the position of the player to be one of C L R F D G

=item C<test_strength>

Tests the event's strength to be one of EV, SH, PP, PS or XX (unknown)

=item C<test_team_header>

Tests "header" information for a team: shots, score, coach etc.

=item C<test_teams>

Tests teams that played in the game

=item C<test_time>

Tests the time to be of format M{1,3}:SS

=back

=cut

our $TEST_COUNTER = {Curr_Test => 0, Test_Results => []};

our @EXPORT = qw(
	my_like my_ok my_is
	test_game_id test_team_id test_team_code
	test_stage test_season test_season_id
	test_ts test_game_date
	test_header test_periods test_officials test_teams test_events test_boxscore
	$TEST_COUNTER
	$EVENT $BOXSCORE $PLAYER $TEAM
);

our $DO_NOT_DIE = 0;
our $TEST_ERRORS = {};
our $MESSAGE = '';
our $THIS_SEASON;

our $EVENT;
our $BOXSCORE;
our $PLAYER;

$Data::Dumper::Trailingcomma = 1;
$Data::Dumper::Deepcopy      = 1;
$Data::Dumper::Sortkeys      = 1;
$Data::Dumper::Deparse       = 1;

sub my_die ($) {

	my $message = shift;
	if ($DO_NOT_DIE) {
		my $field;
		my $object;
		if ($EVENT) {
			$field = 'events';
			$object = $EVENT;
		}
		elsif ($PLAYER) {
			$field = 'players';
			$object = $PLAYER;
		}
		else {
			$field = 'boxscore';
			$object = $BOXSCORE;
		}
		$TEST_ERRORS->{$field} ||= [];
		push(
			@{$TEST_ERRORS->{$field}},
			{
				_id => $object->{_id} || $object->{event_idx} || $object->{number},
				message => $MESSAGE,
			}
		);
		#store $TEST_ERRORS, 'test-errors.storable';
		return;
	}
	$message .= "\n" unless $message =~ /\n$/;
	my $c = 0;
	my $offset = '';
	while (my @caller = caller($c++)) {
		$message .= sprintf(
			"%sCalled in %s::%s, line %d in %s\n",
			$offset, $caller[0], $caller[3], $caller[2], $caller[1]
		);
		$offset .= '  ';
	}
	die $message;
}

sub my_test ($@) {

	my $test = shift;
	$TEST_COUNTER->{Curr_Test}++;
	no warnings 'uninitialized';
	if (@_ == 2) {
		$MESSAGE = "Failed $_[-1]: $_[0]";
	}
	else {
		if (ref $_[1] && ref $_[1] eq 'ARRAY') {
			my $arg1 = join('/', @{$_[1]});
			$MESSAGE = "Failed $_[-1]: $_[0] vs $arg1\n";
		}
		else {
			$MESSAGE = "Failed $_[-1]: $_[0] vs $_[1]\n";
		}
	}
	if ($test->(@_)) {
		$TEST_COUNTER->{Test_Results}[0]++;
	}
	else {
		$TEST_COUNTER->{Test_Results}[1]++;
		my_die($MESSAGE);
	}
	use warnings FATAL => 'all';
	debug "ok_$TEST_COUNTER->{Curr_Test} - $_[-1]" if $0 =~ /\.t$/;
}

sub my_like ($$$) { my_test(sub { no warnings 'uninitialized'; $_[0] =~ $_[1]  }, @_) }
sub my_is   ($$$) { my_test(sub { no warnings 'uninitialized'; $_[0] eq $_[1]  }, @_) }
sub my_ok   ($$)  { my_test(sub { no warnings 'uninitialized'; $_[0]           }, @_) }
sub my_is_one_of ($$$) { my_test(sub { no warnings 'uninitialized'; grep { $_[0] ==  $_ } @{$_[1]}}, @_) }

sub test_season ($$) {
	my $season  = shift;
	my $message = shift;
	my_ok($season >= $FIRST_SEASON, $message); my_ok($season <= $CURRENT_SEASON, $message);
	$THIS_SEASON = $season;
}

sub test_stage ($$) {
	my $stage   = shift;
	my $message = shift;
	my_ok($stage >= $REGULAR, 'stage ok'); my_ok($stage <= $PLAYOFF, $message);
}

sub test_season_id ($$) {
	my $id      = shift;
	my $message = shift;
	my_ok($id > 0, $message); my_ok($id < 1500, $message);
}

sub test_game_id ($$;$) {
	my $id      = shift;
	my $message = shift;
	my $is_nhl  = shift || 0;

	$is_nhl
		? $id =~ /^(\d{4})(\d{2})(\d{4})$/
		: $id =~ /^(\d{4})(\d{1})(\d{4})$/;
	test_season($1, $message); test_stage($2, $message); test_season_id($3, $message);
}

sub test_team_code ($$) {
	my_like(shift, qr/^\w{3}$/, shift .' tri letter code a team');
}

sub test_team_id ($$)   { test_team_code($_[0],$_[1]) && my_ok($TEAMS{$_[0]}, "$_[0] team defined")};
sub test_ts ($$)        { my_like(shift, qr/^-?\d+$/, shift) }
sub test_game_date ($$) { my_like(shift, qr/^\d{8}$/,  shift) }

sub is_unapplicable ($) {
	my $data = shift;

	$THIS_SEASON < ($DATA_BY_SEASON{$data} || $data)
		|| $EVENT && $EVENT->{time} eq '00:00' && $EVENT->{period} < 2;
};

sub is_noplay_event ($) {
	my $event = shift;

        $event->{type} eq 'PEND'    || $event->{type} eq 'PSTR'
        || $event->{type} eq 'GEND' || $event->{type} eq 'STOP';
}

sub test_header ($) {

	my $bs = shift;

	test_season(   $bs->{season},    'header season ok');
	test_stage(    $bs->{stage},     'header stage ok');
	test_season_id($bs->{season_id}, 'header season id ok');
	test_game_id(  $bs->{_id},       'header game id ok');

	my_is($bs->{status}, 'FINAL', 'only final games');
	my_ok($bs->{location}, 'location set') unless is_unapplicable('location');

	my_like($bs->{ot}, qr/^0|1$/, 'OT detected')
		if @{$bs->{periods}} > 3;
	my_like($bs->{so}, qr/^0|1$/, 'SO detected')
		if @{$bs->{periods}} > 4 && $bs->{stage} == $REGULAR;
	if ($bs->{so} && ref $bs->{shootout}) {
		for my $team (qw(away home)) {
			for my $stat (qw(attempts scores)) {
				#print Dumper $bs->{shootout};
				my_like($bs->{shootout}{$team}{$stat}, qr/^\d+$/, 'shootout stat ok');
			}
		}
	}
}

sub test_officials ($;$) {

	my $officials = shift;
	return 1; # for now

	for my $o (qw(referees linesmen)) {
		#my_ok(scalar(@{$officials->{$o}}) >= 1, 'Some officials')
		#	unless defined $NOT_TWO_OFFICIALS{$BOXSCORE->{_id}};
		for my $of (@{$officials->{$o}}) {
			my_ok($of->{name}, 'name set');
		}
	}
}

sub test_name      ($$) { my_like(shift, qr/\w|\.\s+\w/,           shift.' first and last name')   ; }
sub test_player_id ($$) { my_like(shift, qr/^8\d{6}$/,             shift.' valid player id')       ; }
sub test_time      ($$) { my_like(shift, qr/^\-?\d{1,3}:\d{1,2}$/, shift.' valid time')            ; }
sub test_position  ($$) { my_like(shift, qr/^(C|R|W|F|D|L|G)$/,      shift.' valid pos defined')     ; }
sub test_decision  ($$) { my_like(shift, qr/^W|L|O|T$/,            shift.' valid decision')        ; }
sub test_strength  ($$) { my_like(shift, qr/^EV|SH|PP|PS|XX$/,     shift.' valid strength')        ; }

sub test_periods ($) {

	my $periods = shift;

	for my $p (0..4) {
		my $period = $periods->[$p];
		next if ! $period && $p > 2;
		my_is($period->{id}, $p+1, 'period id ok');
		my_like($period->{type}, qr/^REGULAR|OVERTIME$/, 'period time ok');
		my_is(scalar(@{$period->{score}}), 4, '4 items in score');
		for my $gssg (@{$period->{score}}) {
			my_like($gssg, qr/^\d+$/, 'gssg in period a number');
		}
	}
}

sub test_coords ($) {

	my $coords = shift;

	return if scalar keys %{$coords} < 2;
	my_is(scalar(keys %{$coords}), 2, '2 coords');

	for my $coord (keys %{$coords}) {
		my_like($coord, qr/^x|y$/, 'coord x or y');
		my_like($coords->{$coord}, qr/^\-?\d+$/, 'event coord ok');
	}
}

sub test_team_header ($;$) {

	my $team = shift;
	my $opts = shift || {};

	test_team_code($team->{name},  'team name ok')
		unless $opts->{es} || $opts->{gs} || $opts->{ro};
	test_name(     $team->{coach}, 'team coach ok')
		unless $opts->{es} || $opts->{gs};
	my_like($team->{shots}, qr/^\d{1,2}$/, 'shots a number') if $opts->{bs};
	my_like($team->{score}, qr/^1?\d$/, 'goals < 20');
	my_like($team->{pull},  qr/^1|0$/, 'goalie either pulled or not') if $opts->{bs};
	for my $scratch (@{$team->{scratches}}) {
		$opts->{ro} ?
			test_name($scratch->{name}, 'scratch name ok in ro') :
			test_player_id($scratch, 'scratch id ok');
	}
}

sub set_tested_stats ($$) {

	my $player = shift;
	my $opts   = shift || {};

	my @stats;
	if ($opts->{gs}) {
		@stats = $player->{old} ?
			qw(timeOnIce shots saves goals) :
			qw(timeOnIce number powerPlayTimeOnIce shortHandedTimeOnIce evenTimeOnIce shots saves goals);
	}
	elsif ($opts->{ro}) {
		@stats = qw(number start);
	}
	elsif ($opts->{es}) {

	}
	else {
		@stats = $player->{position} eq 'G' ?
			qw(pim evenShotsAgainst shots timeOnIce shortHandedShotsAgainst assists shortHandedSaves powerPlayShotsAgainst powerPlaySaves evenSaves number saves goals) :
			qw(penaltyMinutes shortHandedAssists goals evenTimeOnIce takeaways blocked assists hits powerPlayTimeOnIce plusMinus powerPlayGoals giveaways faceoffTaken faceOffWins shortHandedGoals powerPlayAssists number timeOnIce shots shortHandedTimeOnIce);
	}
	@stats;
}

sub test_player ($;$) {

	my $player = shift;
	my $opts   = shift || {};

	my @stats = set_tested_stats($player, $opts);
	test_position($player->{position}, 'roster position ok');
	for my $stat (@stats) {
		next if is_unapplicable($STAT_RECORD_FROM{$stat})
			|| $player->{position} eq 'G' && $opts->{es};
		if (! defined $player->{$stat}) {print Dumper $stat, $player;exit;}
		$stat =~ /timeonice/i ?
			$opts->{es} || $opts->{gs} ?
				my_like($player->{$stat}, qr/^\d{1,5}$/, "ES $stat ok") :
				test_time($player->{$stat}, "$stat timeonice ok") :
			my_like($player->{$stat}, qr/\-?\d{1,2}/, "stat $stat an integer");
	}
	test_name($player->{name}, 'player name ok');
	test_player_id($player->{_id}, 'roster id ok')
		unless $opts->{es} || $opts->{gs} || $opts->{ro};

}

sub test_teams ($;$) {

	my $teams = shift;
	my $opts  = shift || {};

	for my $team (@{$teams}) {
		test_team_header($team, $opts);
		my $decision = '';
		my $broken = 0;
		for my $player (@{$team->{roster}}) {
			next if $player->{_id} && $player->{_id} =~ /^80/;
			$PLAYER = $player;
			if ($player->{broken}) {
				$broken = 1;
				next;
			}
			test_player($player, $opts);
			if (! $decision) {
				$decision = $player->{decision};
			}
			elsif ($player->{decision}) {
				die "Cannot have two decisions";
			}
			undef $PLAYER;
		}
		test_decision($decision, 'game decision ok')
			unless $broken
			|| $BOXSCORE->{_gs_no_g}
			|| $opts->{es}
			|| $opts->{ro};
			#	|| $team->{no_goalie}
			#|| !grep {$_->{position} eq 'G'} @{$team->{roster}};
		$team->{decision} = $decision if $opts->{merged};
	}
	undef $PLAYER;
}

sub test_event_strength ($$$) {

	my $event   = shift;
	my $opts    = shift;
	my $message = shift;

	test_strength($event->{strength}, $message)
		if $event->{type} eq 'GOAL' || $opts->{merged} && (
			!$BROKEN_TIMES{$BOXSCORE->{_id}}
				&& $event->{type} ne 'CHL'
				&& !($event->{type} eq 'PENL' && ! $event->{sources}{PL})
				&& ($event->{type} eq 'GOAL' || $BOXSCORE->{sources}{PL}
				&& ! is_noplay_event($event))
				&& !($event->{type} eq 'MISS' && ! $event->{sources}{PL})
		);
}

sub test_event_coords ($) {
	my $event = shift;

	test_coords($event->{coordinates})
		if !is_unapplicable('coordinates')
			&& !is_noplay_event($event)
			&& !($event->{penalty})
			&& !($BROKEN_COORDS{$BOXSCORE->{_id}});
}

sub test_event_description ($) {
	my $event = shift;

	my_like($event->{description}, qr/\w/, 'event description exists')
		if $BOXSCORE->{sources}{BS}
			&& !$BROKEN_FILES{$BOXSCORE->{_id}}->{BS}
			|| $BOXSCORE->{sources}{PL};
}

sub test_assists_and_servedby ($$) {
	my $event = shift;
	my $opts  = shift || {};

	if ($event->{servedby}) {
		$opts->{pl} ?
			my_like($event->{player1}, qr/^(\d{1,2}|80\d{5})$/, 'pl player1 number ok') :
			test_player_id($event->{servedby}, 'servedby player id ok');
	}
	if ($event->{assists} && @{$event->{assists}}) {
		for my $assist (@{$event->{assists}}) {
			$opts->{pl} ?
				my_like($event->{player1}, qr/^(\d{1,2}|80\d{5})$/, 'pl assist number ok') :
				test_player_id($assist, 'assist id ok');
		}
	}
}

sub test_player1 ($$) {
	my $event = shift;
	my $opts  = shift;

	if (($opts->{gs} && ! $event->{old}) || $opts->{pl}) {
		my_like($event->{player1}, qr/^(\d{1,2}|80\d{5})$/, 'gs pl player1 number ok');
	}
	else {
		$DO_NOT_DIE = 1;
		test_player_id($event->{player1}, 'event player1 ok')
			unless $opts->{gs}
				|| ($event->{type} eq 'PENL'
				&& ($event->{time} eq '20:00'
				|| $PENALTY_POSSIBLE_NO_OFFENDER{$event->{penalty}})
			);
		$DO_NOT_DIE = 0;
	}
}

sub test_player2 ($$) {
	my $event = shift;
	my $opts  = shift;

	test_player_id($event->{player2}, 'event player2 ok')
		unless ($event->{type} eq 'GOAL' && $event->{en})
			|| ($event->{type} eq 'GOAL' && $opts->{bh} || $opts->{gs} || $opts->{pl})
			|| ($opts->{merged} && ! $event->{sources}{BS} && $event->{type} eq 'GOAL')
			|| ($event->{time} eq '0:00' && $event->{type} ne 'FAC');
}

sub test_goal ($$) {
	my $event = shift;
	my $opts  = shift;

	unless (
		$opts->{pb} || $opts->{pl} || $event->{so}
		|| $BROKEN_FILES{BS}->{$BOXSCORE->{_id}}
	) {
		my_like($event->{en}, qr/^0|1$/, 'en definition');
		my_like($event->{gwg}, qr/^0|1$/, 'gwg definition')
			unless $opts->{bh} || $opts->{gs};
	}
}

sub test_penalty ($$) {
	my $event = shift;
	my $opts  = shift;
	unless ($opts->{pb}) {
		my_like(
			$event->{severity},
			qr/^major|misconduct|minor|game|match|double|shot$/i, 'severity defined'
		) unless is_unapplicable('severity')
			|| $opts->{bh}
			|| $opts->{gs}
			|| $opts->{pl}
			|| !$event->{length}
			|| $BROKEN_FILES{BS}->{$BOXSCORE->{_id}};
		my_ok($VOCABULARY{penalty}->{$event->{penalty}}, "$event->{penalty} Good penalty type");
		my_like($event->{length}, qr/^0|2|3|4|5|10$/, 'length defined');
	}
}

sub test_event_by_type ($$) {
	my $event = shift;
	my $opts  = shift;

	my_ok($VOCABULARY{events}->{$event->{type}}, "$event->{type} Good event type");
	my_ok($VOCABULARY{strength}->{$event->{strength}}, 'Good event strength')
		if exists $event->{strength};
	for ($event->{type}) {
		when ([ qw(FAC HIT BLOCK GOAL SHOT PENL MISS GIVE TAKE) ]) {
			test_player1($event, $opts);
			continue;
		}
		when ([ qw(FAC HIT BLOCK GOAL) ]) {
			test_player2($event, $opts);
			continue;
		}
		when ('STOP') {
			my_is(ref $event->{stopreason}, 'ARRAY', 'stopreason is array');
			for my $reason (@{$event->{stopreason}}) {
				my_ok(
					$VOCABULARY{stopreason}->{$reason},
					"$reason there is a good reason to stop",
				);
			}
			continue;
		}
		when ([ qw(GOAL SHOT) ]) {
			my_ok(
				$VOCABULARY{shot_type}->{$event->{shot_type}},
				"$event->{shot_type} shot type normalized",
			);
			continue;
		}
		when ([ qw(GOAL) ]) {
			test_goal($event, $opts);
			continue;
		}
		when ([ qw(MISS) ]) {
			my_ok(
				$VOCABULARY{miss}->{$event->{miss}},
				'miss type normalized',
			);
			my_like($event->{description}, qr/\w/, 'miss needs description')
				unless $event->{penaltyshot};
			continue;
		}
		when ([ qw(PENL) ]) {
			test_penalty($event, $opts);
			continue;
		}
	}

}

sub test_event ($;$) {

	my $event = shift;
	my $opts  = shift || {};

	$EVENT = $event;
	my_like($event->{period}, qr/^\d$/, 'event period ok');
	test_time($event->{time}, 'event time ok');
	test_event_strength($event, $opts, "event $event->{type}/$event->{time}");
	test_event_coords($event);
	test_event_description($event);
	my_ok($VOCABULARY{events}->{$event->{type}}, 'valid type');
	test_assists_and_servedby($event, $opts);
	test_event_by_type($event, $opts);
	undef $EVENT;
}

sub test_events ($;$) {

	my $events = shift;
	my $opts   = shift || {};

	my $event_n = scalar @{$events};

	my_ok($event_n >= $REASONABLE_EVENTS{
		$BOXSCORE->{season} < 2010 ? 'old' : 'new'
	}, "enough events($event_n) read")
		unless ($opts->{bs} && $BROKEN_FILES{$BOXSCORE->{_id}}{BS})
			|| $opts->{bh} || $opts->{gs};
	for my $event (@{$events}) {
		test_event($event, $opts);
	}
	undef $EVENT;
}

sub test_boxscore ($;$) {

	my $boxscore = shift;
	my $opts     = shift || {bs => 0};

	$BOXSCORE = $boxscore;
	test_header($boxscore);
	test_periods($boxscore->{periods}) if $opts->{bs};
	test_officials($boxscore->{officials}, $opts)
		if ! $opts->{es} && ! $opts->{pl} && $boxscore->{season} >= $DATA_BY_SEASON{officials};
	test_teams($boxscore->{teams}, $opts) if ! $opts->{pl};
	test_events($boxscore->{events}, $opts) unless
		$BROKEN_FILES{BS}->{$BOXSCORE->{_id}} || $opts->{es} || $opts->{ro};
	undef $BOXSCORE;
	undef $PLAYER;
	undef $EVENT;
}

END {
	if ($BOXSCORE) {
		$Data::Dumper::Varname = 'BOXSCORE';
		#print Dumper $BOXSCORE;
	}
	if ($EVENT) {
		$Data::Dumper::Varname = 'EVENT';
		print Dumper $EVENT;
	}
	if ($PLAYER) {
		$Data::Dumper::Varname = 'PLAYER';
		print Dumper $PLAYER;
	}
}

1;

=head1 AUTHOR

More Hockey Stats, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Test>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Test

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Test>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Test>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Test>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Test>

=back
