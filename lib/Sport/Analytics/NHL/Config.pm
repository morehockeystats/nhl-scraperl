package Sport::Analytics::NHL::Config;

use strict;
use warnings FATAL => 'all';

use parent 'Exporter::Tiny';

=head1 NAME

Sport::Analytics::NHL::Config - NHL-related configuration settings

=head1 SYNOPSYS

NHL-related configuration settings

Provides NHL-related settings such as first and last season, teams, available reports, and so on.

This list shall expand as the release grows.

    use Sport::Analytics::NHL::Config qw(:seasons;
    print "The first active NHL season is $FIRST_SEASON\n";

By default nothing is exported. You can import the functions either by name, or by the tags listed below, or by tag ':all'.

seasons: season-related data

basic: basic constants (e.g. $REGULAR, $PLAYOFF)

league: league-related constants (%TEAMS, %TEAM_FULL_NAMES)

=cut

our $FIRST_SEASON    =  1917;
our @LOCKOUT_SEASONS = (2004);
our $DELAYED_START   =  2020;
our $DELAYED_STOP    =  2019;

our %FIRST_REPORT_SEASONS = (
        BS => $FIRST_SEASON,
        #PB => 2010,
        GS => 1999,
        ES => 1999,
        TV => 2007,
        TH => 2007,
        PL => 2002,
        RO => 2005,
);

our $REGULAR = 2;
our $PLAYOFF = 3;

our %TEAMS = (
	MWN => {
		defunct => 1,
		long    => [],
		short   => [],
		founded => $FIRST_SEASON,
		folded  => $FIRST_SEASON + 1,
		full    => [ ('Montreal Wanderers') ],
	},
	MMR => {
		defunct => 1,
		long    => [],
		short   => [],
		founded => 1924,
		folded  => 1938,
		full    => [ ('Montreal Maroons') ],
	},
	BRK => {
		defunct  => 1,
		long     => [],
		short    => [ 'NYA' ],
		timeline => {
			NYA => [ 1925, 1940 ],
			BRK => [ 1941, 1941 ],
		},
		founded  => 1925,
		folded   => 1942,
		full     => [ ('Brooklyn Americans', 'New York Americans') ],
	},
	PIR => {
		long     => [],
		defunct  => 1,
		founded  => 1925,
		folded   => 1931,
		short    => [ 'QUA' ],
		timeline => {
			PIR => [ 1925, 1929 ],
			QUA => [ 1930, 1930 ],
		},
		full     => [ ('Pittsburgh Pirates', 'Philadelphia Quakers') ],
	},
	VMA => {
		defunct => 1,
		long    => [],
		short   => [ 'VMI' ],
		full    => [ ('Vancouver Maroons', 'Vancouver Millionaires') ],
	},
	MET => {
		long    => [],
		defunct => 1,
		short   => [ qw(SEA SMT) ],
		full    => [ ('Seattle Metropolitans') ],
	},
	VIC => {
		long    => [],
		defunct => 1,
		short   => [],
		full    => [ ('Victoria Cougars') ],
	},
	HAM => {
		defunct  => 1,
		long     => [],
		short    => [ 'QBD', 'QAL' ],
		timeline => {
			QAL => [ 1919, 1919 ],
			HAM => [ 1920, 1924 ],
		},
		founded  => 1919,
		folded   => 1925,
		full     => [ ('Hamilton Tigers', 'Quebec Bulldogs', 'Quebec Athletics') ],
	},
	CAT => {
		defunct => 1,
		long    => [],
		short   => [],
		full    => [ ('Calgary Tigers') ],
	},
	EDE => {
		defunct => 1,
		long    => [],
		short   => [],
		full    => [ ('Edmonton Eskimos') ],
	},
	SEN => {
		defunct => 1,
		founded => $FIRST_SEASON,
		folded  => 1935,
		long    => [],
		short   => [ 'SLE' ],
		full    => [ ('Ottawa Senators (1917)', 'St. Louis Eagles') ],
	},
	VGK => {
		long    => [ qw(Vegas Golden Knights), 'Golden Knights', 'Knights' ],
		short   => [],
		founded => 2017,
		full    => [ ('Vegas Golden Knights') ],
		twitter => '@GoldenKnights',
		hashtag => '#VegasBorn',
		color   => 'darkgoldenrod',
	},
	MIN => {
		long    => [ qw(Minnesota Wild) ],
		short   => [],
		founded => 2000,
		full    => [ ('Minnesota Wild') ],
		twitter => '@mnwild',
		hashtag => '#mnwild',
		color   => 'darkgreen',
	},
	WPG => {
		long    => [ qw(Winnipeg Jets Thrashers) ],
		short   => [ qw(ATL) ],
		founded => 1999,
		full    => [ ('Winnipeg Jets', 'Atlanta Thrashers') ],
		twitter => '@NHLJets',
		hashtag => '#GoJetsGo',
		color   => 'blue3',
	},
	NJD => {
		long     => [ qw(Devils Rockies Scouts Jersey), 'New Jersey' ],
		short    => [ qw(CLR KCS NJD NJ N.J) ],
		founded  => 1974,
		timeline => {
			CLR => [ 1976, 1981 ],
			KCS => [ 1974, 1975 ],
		},
		full     => [ ('New Jersey Devils', 'Colorado Rockies', 'Kansas City Scouts') ],
		twitter  => '@NJDevils',
		hashtag  => '#NJDevils',
		color    => 'black',
	},
	ARI => {
		long     => [ qw(Arizona Phoenix Coyotes), 'Jets (1979)' ],
		short    => [ qw(PHX WIN) ],
		founded  => 1979,
		timeline => {
			WIN => [ 1979, 1995 ],
			PHX => [ 1995, 2014 ],
		},
		full     => [ ('Arizona Coyotes', 'Phoenix Coyotes', 'Winnipeg Jets (1979)') ],
		twitter  => '@ArizonaCoyotes',
		hashtag  => '#Yotes',
		color    => 'DebianRed',
	},
	PIT => {
		long    => [ qw(Pittsburgh Penguins) ],
		short   => [ qw() ],
		founded => 1967,
		full    => [ ('Pittsburgh Penguins') ],
		twitter => '@penguins',
		hashtag => '#LetsGoPens',
		color   => 'gold2',
	},
	VAN => {
		long    => [ qw(Vancouver Canucks) ],
		short   => [ qw() ],
		founded => 1970,
		full    => [ ('Vancouver Canucks') ],
		twitter => '@Canucks',
		hashtag => '#Canucks',
		color   => 'cyan3',
	},
	NYI => {
		long    => [ qw(Islanders), 'NY Islanders' ],
		short   => [ qw() ],
		founded => 1972,
		full    => [ ('New York Islanders') ],
		twitter => '@NYIslanders',
		hashtag => '#Isles',
		color   => 'sandybrown',
	},
	CBJ => {
		long    => [ qw(Columbus Blue Jackets), 'Blue Jackets' ],
		short   => [ qw(CBS) ],
		founded => 2000,
		full    => [ ('Columbus Blue Jackets') ],
		twitter => '@BlueJacketsNHL',
		hashtag => '#CBJ',
		color   => 'blueviolet',
	},
	ANA => {
		long    => [ qw(Anaheim Ducks) ],
		short   => [ qw() ],
		founded => 1993,
		full    => [ ('Anaheim Ducks', 'Mighty Ducks Of Anaheim') ],
		twitter => '@AnaheimDucks',
		hashtag => '#LetsGoDucks',
		color   => 'orange',
	},
	PHI => {
		long    => [ qw(Philadelphia Flyers) ],
		short   => [ qw() ],
		founded => 1967,
		full    => [ ('Philadelphia Flyers') ],
		twitter => '@NHLFlyers',
		hashtag => '#NowOrNever',
		color   => 'chartreuse2',
	},
	CAR => {
		long     => [ qw(Carolina Hurricanes Whalers) ],
		short    => [ qw(HFD) ],
		founded  => 1979,
		timeline => {
			HFD => [ 1979, 1996 ],
		},
		full     => [ ('Carolina Hurricanes', 'Hartford Whalers') ],
		twitter  => '@NHLCanes',
		hashtag  => '#LetsGoCanes',
		color    => 'tomato',
	},
	NYR => {
		long    => [ qw(Rangers), 'NY Rangers' ],
		short   => [ qw() ],
		founded => 1926,
		full    => [ ('New York Rangers') ],
		twitter => '@NYRangers',
		hashtag => '#PlayLikeANewYorker',
		color   => 'steelblue',
	},
	CGY => {
		long     => [ qw(Calgary Flames) ],
		short    => [ qw(AFM) ],
		founded  => 1972,
		full     => [ ('Calgary Flames', 'Atlanta Flames') ],
		timeline => {
			AFM => [ 1972, 1979 ],
		},
		twitter  => '@NHLFlames',
		hashtag  => '#Flames',
		color    => 'coral1',
	},
	BOS => {
		long    => [ qw(Boston Bruins) ],
		short   => [ qw() ],
		founded => 1924,
		full    => [ ('Boston Bruins') ],
		twitter => '@NHLBruins',
		hashtag => '#NHLBruins',
		color   => 'yellow1',
	},
	CLE => {
		defunct  => 1,
		founded  => 1967,
		folded   => 1978,
		long     => [ qw(Barons Seals) ],
		timeline => {
			CSE => [ 1966, 1966 ],
			OAK => [ 1967, 1969 ],
			CGS => [ 1970, 1975 ],
		},
		short    => [ qw(CSE OAK CGS CBN) ],
		full     => [ ('Cleveland Barons', 'California Golden Seals', 'Oakland Seals') ],
	},
	EDM => {
		long    => [ qw(Edmonton Oilers) ],
		short   => [ qw() ],
		founded => 1979,
		full    => [ ('Edmonton Oilers') ],
		twitter => '@EdmontonOilers',
		hashtag => '#LetsGoOilers',
		color   => 'wheat1',
	},
	MTL => {
		long    => [ qw(Canadiens Montreal) ],
		short   => [ qw(MON) ],
		founded => $FIRST_SEASON,
		full    => [ ('Montreal Canadiens', 'Montréal Canadiens', 'Canadiens de Montreal', 'Canadiens Montreal', 'Canadien De Montreal') ],
		twitter => '@CanadiensMTL',
		hashtag => '#GoHabsGo',
		color   => 'maroon',
	},
	STL => {
		long    => [ qw(Blues Louis), ],
		short   => [ qw() ],
		founded => 1967,
		full    => [ ('St. Louis Blues', 'St.Louis Blues', 'St Louis', 'St. Louis', 'ST Louis Blues') ],
		twitter => '@StLouisBlues',
		hashtag => '#stlblues',
		color   => 'moccasin',
	},
	TOR => {
		long     => [ qw(Toronto Maple Leafs), 'Maple Leafs' ],
		short    => [ qw(TAN TSP) ],
		timeline => {
			TAN => [ 1917, 1918 ],
			TSP => [ 1919, 1926 ],
		},
		founded  => $FIRST_SEASON,
		full     => [ ('Toronto Maple Leafs', 'Toronto Arenas', 'Toronto St. Patricks') ],
		twitter  => '@MapleLeafs',
		hashtag  => '#LeafsForever',
		color    => 'dodgerblue1',
	},
	FLA => {
		long    => [ qw(Florida Panthers) ],
		short   => [ qw(FLO) ],
		founded => 1993,
		full    => [ ('Florida Panthers') ],
		twitter => '@FlaPanthers',
		hashtag => '#FlaPanthers',
		color   => 'olivedrab',
	},
	BUF => {
		long    => [ qw(Buffalo Sabres) ],
		short   => [ qw() ],
		founded => 1970,
		full    => [ ('Buffalo Sabres') ],
		twitter => '@BuffaloSabres',
		hashtag => '#Sabres50',
		color   => 'greenyellow',
	},
	NSH => {
		long    => [ qw(Nashville Predators) ],
		short   => [ qw() ],
		founded => 1998,
		full    => [ ('Nashville Predators') ],
		twitter => '@PredsNHL',
		hashtag => '#Preds',
		color   => 'darkkhaki',
	},
	SJS => {
		long    => [ qw(San Jose Sharks), 'San Jose' ],
		short   => [ qw(SJS S.J SJ) ],
		founded => 1991,
		full    => [ ('San Jose Sharks') ],
		twitter => '@SanJoseSharks',
		hashtag => '#SJSharks',
		color   => 'teal',
	},
	COL => {
		long     => [ qw(Nordiques Colorado Avalanche) ],
		short    => [ qw(QUE) ],
		founded  => 1979,
		timeline => {
			QUE => [ 1979, 1994 ],
		},
		full     => [ ('Colorado Avalanche', 'Quebec Nordiques') ],
		twitter  => '@Avalanche',
		hashtag  => '#GoAvsGo',
		color    => 'mediumvioletred',
	},
	DAL => {
		long     => [ 'North Stars', qw(Dallas Stars) ],
		founded  => 1967,
		short    => [ qw(MNS MINS) ],
		timeline => {
			MNS => [ 1967, 1992 ],
		},
		full     => [ ('Dallas Stars', 'Minnesota North Stars') ],
		twitter  => '@DallasStars',
		hashtag  => '#GoStars',
		color    => 'mediumseagreen',
	},
	OTT => {
		long    => [ qw(Ottawa Senators) ],
		short   => [ qw() ],
		founded => 1992,
		full    => [ ('Ottawa Senators') ],
		twitter => '@Senators',
		hashtag => '#GoSensGo',
		color   => 'pink',
	},
	LAK => {
		long    => [ qw(Kings Angeles), 'Los Angeles' ],
		short   => [ qw(LAK L.A LA) ],
		founded => 1967,
		full    => [ ('Los Angeles Kings') ],
		twitter => '@LAKings',
		hashtag => '#GoKingsGo',
		color   => 'grey',
	},
	TBL => {
		long    => [ qw(Lightning Bay), 'Tampa Bay' ],
		founded => 1992,
		short   => [ qw(TBL T.B TB) ],
		full    => [ ('Tampa Bay Lightning') ],
		twitter => '@TBLightning',
		hashtag => '#GoBolts',
		color   => 'LightSkyBlue3',
	},
	DET => {
		long     => [ qw(Detroit Red Wings), 'Wings', 'Red Wings' ],
		short    => [ qw(DCG DFL) ],
		founded  => 1926,
		timeline => {
			DCG => [ 1926, 1929 ],
			DFL => [ 1930, 1931 ],
		},
		full     => [ ('Detroit Red Wings', 'Detroit Cougars', 'Detroit Falcons') ],
		twitter  => '@DetroitRedWings',
		hashtag  => '#LGRW',
		color    => 'red1',
	},
	CHI => {
		long    => [ ('Blackhawks', 'Black Hawks', 'Chicago') ],
		short   => [ qw() ],
		founded => 1926,
		full    => [ ('Chicago Blackhawks', 'Chicago Black Hawks') ],
		twitter => '@NHLBlackhawks',
		hashtag => '#Blackhawks',
		color   => 'orangered',
	},
	WSH => {
		long    => [ qw(Washington Capitals) ],
		short   => [ qw(WAS) ],
		founded => 1974,
		full    => [ ('Washington Capitals') ],
		twitter => '@Capitals',
		hashtag => '#ALLCAPS',
		color   => 'darkslategray',
	},
);

our %TEAM_FULL_NAMES = (
	TAN => 'Toronto Arenas',
	TSP => 'Toronto St. Patricks',
	QAL => 'Quebec Athletics',
	MWN => 'Montreal Wanderers',
	MMR => 'Montreal Maroons',
	BRK => 'Brooklyn Americans',
	NYA => 'New York Americans',
	PIR => 'Pittsburgh Pirates',
	QUA => 'Philadelphia Quakers',
	VMA => 'Vancouver Maroons',
	VMI => 'Vancouver Millionaires',
	MET => 'Seattle Metropolitans',
	SEA => 'Seattle Metropolitans',
	VIC => 'Victoria Cougars',
	HAM => 'Hamilton Tigers',
	QBD => 'Quebec Bulldogs',
	CAT => 'Calgary Tigers',
	EDE => 'Edmonton Eskimos',
	DCG => 'Detroit Cougars',
	DFL => 'Detroit Falcons',
	CLR => 'Colorado Rockies',
	SEN => 'Ottawa Senators (1917))',
	SLE => 'St. Louis Eagles',
	MIN => 'Minnesota Wild',
	WPG => 'Winnipeg Jets',
	ATL => 'Atlanta Thrashers',
	NJD => 'New Jersey Devils',
	CLR => 'Colorado Rockies',
	KCS => 'Kansas City Scouts',
	WIN => 'Winnipeg Jets (1979)',
	PHX => 'Phoenix Coyotes',
	ARI => 'Arizona Coyotes',
	PIT => 'Pittsburgh Penguins',
	VAN => 'Vancouver Canucks',
	NYI => 'New York Islanders',
	CBJ => 'Columbus Blue Jackets',
	ANA => {
		2005    => 'Mighty Ducks Of Anaheim',
		default => 'Anaheim Ducks',
	},
	PHI => 'Philadelphia Flyers',
	CAR => 'Carolina Hurricanes',
	HFD => 'Hartford Whalers',
	NYR => 'New York Rangers',
	CGY => 'Calgary Flames',
	AFM => 'Atlanta Flames',
	BOS => 'Boston Bruins',
	CBN => 'Cleveland Barons',
	CSE => 'California Golden Seals',
	CGS => 'California Golden Seals',
	OAK => 'Oakland Seals',
	EDM => 'Edmonton Oilers',
	MTL => 'Montreal Canadiens',
	STL => 'St. Louis Blues',
	TOR => 'Toronto Maple Leafs',
	FLA => 'Florida Panthers',
	BUF => 'Buffalo Sabres',
	NSH => 'Nashville Predators',
	SJS => 'San Jose Sharks',
	COL => 'Colorado Avalanche',
	QUE => 'Quebec Nordiques',
	DAL => 'Dallas Stars',
	MNS => 'Minnesota North Stars',
	OTT => 'Ottawa Senators',
	LAK => 'Los Angeles Kings',
	TBL => 'Tampa Bay Lightning',
	CHI => {
		1984    => 'Chicago Black Hawks',
		default => 'Chicago Blackhawks',
	},
	DET => 'Detroit Red Wings',
	WSH => 'Washington Capitals',
	VGK => 'Vegas Golden Knights',
);

our @seasons = qw(
	$FIRST_SEASON $DELAYED_START $DELAYED_STOP @LOCKOUT_SEASONS
	%FIRST_REPORT_SEASONS
);
our @basic   = qw($REGULAR $PLAYOFF);
our @league  = qw(%TEAMS %TEAM_FULL_NAMES);

our @EXPORT_OK = (@seasons, @basic, @league);

our %EXPORT_TAGS = (
	seasons => \@seasons,
	basic   => \@basic,
	league  => \@league,
	all     => \@EXPORT_OK,
);

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Config>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Config


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Config>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Config>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Config>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Config>

=back
