package Sport::Analytics::NHL::Errors;

use strict;
use warnings FATAL => 'all';

use Sport::Analytics::NHL::Config;

use parent 'Exporter';

our @EXPORT = qw(
	%BROKEN_FILES %BROKEN_HEADERS
	%BROKEN_COACHES %BROKEN_PLAYERS %BROKEN_EVENTS
	%BROKEN_ROSTERS %BROKEN_PLAYER_IDS
	%BROKEN_TIMES %BROKEN_COORDS
	%NAME_TYPOS
	%SPECIAL_EVENTS
	%MISSING_EVENTS %MISSING_COACHES %MISSING_PLAYERS
);

our %NAME_TYPOS = (
	'BRYCE VAN BRABRANT' => 'BRYCE VAN BRABANT',
	'TOMMY WESTLUND'     => 'TOMMY VESTLUND',
	'MATTIAS JOHANSSON'  => 'MATHIAS JOHANSSON',
	'WESTLUND'           => 'VESTLUND',
	'T. WESTLUND'        => 'T. VESTLUND',
	'N. KRONVALL'        => 'N. KRONWALL',
	'S. KRONVALL'        => 'S. KRONWALL',
	'A. KASTSITSYN'      => 'A. KOSTITSYN',
	'F. MEYER IV'        => 'F. MEYER',
	'P/ BRISEBOIS'       => 'P. BRISEBOIS',
	'K. PUSHKARYOV'      => 'K. PUSHKAREV',
	'M. SATIN'           => 'M. SATAN',
	'B. RADIVOJEVICE'    => 'B. RADIVOJEVIC',
	'J. BULLIS'          => 'J. BULIS',
	'PJ. AXELSSON'       => 'P.J. AXELSSON',
);

our %BROKEN_COACHES = (
	STICKLE                => 'BOB MURDOCH',
	'CASHMAN/THIFFAULT'    => 'MICHEL BERGERON',
	'LEVER/SMITH'          => 'TED SATOR',
	'WILSON/RAEDER'        => 'TOM WEBSTER',
	'RAEDER/WILSON'        => 'TOM WEBSTER',
	'BAXTER/CHARRON'       => 'DOUG RISEBROUGH',
	'CHARRON/BAXTER'       => 'GUY CHARRON',
	'CHARON,BAXTER,HISLOP' => 'GUY CHARRON',
);

our %BROKEN_PLAYER_IDS = (8445204 => 8445202);

our %BROKEN_PLAYERS = (
	BS => {
		192730312 => {
			8448095 => {
				number => 16,
			}
		},
	},
);

our %BROKEN_ROSTERS = (
	198720509 => [ [], [ { 'No.' => 0, number => 30 } ], ],
	199020353 => [ [], [ { 'No.' => 0, number => 30 } ], ],
	199020696 => [ [], [ { 'No.' => 0, number => 35 } ], ],
	199120656 => [ [], [ { 'No.' => 16, penaltyMinutes => 4 }, ], ],
	199120753 => [ [ { 'No.' => 26, penaltyMinutes => 7 }, ], [], ],
	199120809 => [ [ { 'No.' => 5, penaltyMinutes => 2 }, ], [], ],
	199120839 => [ [ { 'No.' => 11, penaltyMinutes => 12 }, ], [], ],
	199120877 => [ [ { 'No.' => 27, penaltyMinutes => 18 }, ], [], ],
	199220449 => [ [ { 'No.' => 29, penaltyMinutes => 18 }, ], [], ],
	199220585 => [ [], [ { 'No.' => 39, penaltyMinutes => 17 }, ], ],
	199320044 => [ [ { 'No.' => 26, penaltyMinutes => 4 }, ], [], ],
	199320074 => [ [ { 'No.' => 27, penaltyMinutes => 4 }, ], [], ],
	199320404 => [ [ { 'No.' => 29, penaltyMinutes => 19 }, ], [], ],
	199320499 => [ [], [ { 'No.' => 32, penaltyMinutes => 2 }, ], ],
	199320640 => [ [], [ { 'No.' => 12, penaltyMinutes => 6 }, ], ],
	199520048 => [ [ { 'No.' => 12, penaltyMinutes => 2, }, ], [], ],
	199520790 => [ [ { 'No.' => 12, penaltyMinutes => 6, }, ], [], ],
	199530123 => [ [], [ { 'No.' => 23, penaltyMinutes => 14, }, ], ],
	199620473 => [ [ { 'No.' => 27, penaltyMinutes => 2, }, ], [], ],
	199620546 => [ [ { 'No.' => 17, penaltyMinutes => 2, }, ], [], ],
	199620548 => [ [ { 'No.' => 33, penaltyMinutes => 23 }, ], [], ],
	199620927 => [ [ { 'No.' => 20, penaltyMinutes => 2, },
		{ 'No.' => 77, penaltyMinutes => 2, }, ], [], ],
	199630222 => [ [], [ { 'No.' => 18, penaltyMinutes => 2, }, ], ],
	199720830 => [ [], [ { 'No.' => 35, 'EV' => '10 - 12' }, ], ],
	199720876 => [ [], [ { 'No.' => 27, 'EV' => '11 - 14' }, ], ],
	199720997 => [ [ { 'No.' => 31, 'SH' => '3 - 3' }, ], [], ],
	199820004 => [ [], [ { 'No.' => 34, 'EV' => '26 - 28' }, ], ],
	199820061 => [ [], [ { 'No.' => 35, 'EV' => '19 - 20' }, ], ],
	200320027 => [ [], [ { 'No.' => 29, 'name' => 'JAMIE MCLENNAN' }, ], ],
	200520312 => [ [ { 'No.' => 7, error => 1 } ], [] ],
);

our %BROKEN_EVENTS = (
	BS => {
		198520010 => { 16 => { time =>  '7:48' }, },
		198520611 => { 32 => { time => '10:09' }, },
		198820689 => {  5 => { player2 => 8446637 }, 6 => { player2 => 8446637 }, },
	},
	BH => {

	},
	PL => {
		200520312 => {
			1 => {
				id          => 1, period => 1, time => '0:00', team => 'NSH', strength => 'EV',
				shot_type   => 'Snap', distance => 18, type => 'GOAL', location => 'Off',
				description => '22 JOHNSON, A: 20 SUTER, 7 UPSHALL, Snap, 18 ft',
				old         => 1, team1 => 'NSH', player1 => 22, assist1 => 20,
				on_ice      => [ [], [], ], special => 1, stage => 2, season => 2005,
			},
		},
		200720028 => { 269 => 0, },
		200820444 => { 190 => { player1 => $UNKNOWN_PLAYER_ID } },
		200820868 => { 299 => { length => 2, penalty => 'Instigator', description => 'EDM #18 MOREAU Instigator(2 min) Drawn By: DAL #29 OTT'}, },
        200821191 => { 289 => { player1 => 20, team1 => 'NSH', player2 => 2, team2 => 'CHI', }, },
		201020596 => { 275 => 0, },
		201020989 => { 346 => { reason => 'GOALIE STOPPED', description => 'GOALIE STOPPED', }, },
        201120094 => { 198 => { reason => 'GOALIE STOPPED', description => 'GOALIE STOPPED', }, },
		201120553 => { 294 => {
			length => 10, penalty => 'Misconduct', misconduct => 1,
			description => 'FLA #21 BARCH Game misconduct(10 min)',
		} },
		201320971 => {   1 => {
			id => 1, period => 1,
			time => '0:00',
			team => 'CBJ',
			strength => 'EV',
			shot_type => 'Snap',
			distance => 18,
			type => 'GOAL',
			location => 'Off',
			old => 1,
			description => 'CBJ #8 HORTON(5), A: 11 CALVERT(4); 21 WISNIEWSKI(43), Snap, 18 ft',
			team1 => 'NSH',
			player1 => 8470596,
			assist1 => 8476485,
			assist2 => 8470222,
			on_ice => [ [], [], ],
			special => 1, en => 0, gwg => 0,
		} },
        201420600 => { 328 => 0 },
        201420921 => { 354 => { reason => 'GOALIE STOPPED', description => 'GOALIE STOPPED', }, },
		201621127 => { 311 => { description => 'BOS #55 ACCIARI Misconduct(10 min), Def. Zone' }},
	},
	GS => {
	}
);

our %BROKEN_TIMES = (

);

our %BROKEN_COORDS = (

);

my $INCOMPLETE = -1;
my $REPLICA    = -2;
my $BROKEN     = -3;

our %BROKEN_FILES = (
	199920029 => { ES => $REPLICA, GS => $REPLICA },
	199920045 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920050 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920058 => { ES => $REPLICA, GS => $REPLICA },
	199920071 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920072 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920081 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920109 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920130 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920323 => { ES => $REPLICA, GS => $REPLICA },
	199920619 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920689 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199920690 => { ES => $BROKEN, GS => $INCOMPLETE },
	199920836 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	199921034 => { BH => $INCOMPLETE, ES => $INCOMPLETE, GS => $INCOMPLETE },
	199930325 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020029 => { ES => $REPLICA, GS => $REPLICA },
	200020038 => { ES => $REPLICA, GS => $REPLICA },
	200020039 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020041 => { ES => $REPLICA, GS => $REPLICA },
	200020042 => { ES => $REPLICA, GS => $REPLICA },
	200020043 => { ES => $REPLICA, GS => $REPLICA },
	200020044 => { ES => $REPLICA, GS => $REPLICA },
	200020045 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020049 => { ES => $REPLICA, GS => $REPLICA },
	200020067 => { ES => $REPLICA, GS => $REPLICA },
	200020072 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020073 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020077 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020080 => { ES => $REPLICA, GS => $REPLICA },
	200020081 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020083 => { ES => $REPLICA, GS => $REPLICA },
	200020085 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020095 => { ES => $REPLICA, GS => $REPLICA },
	200020096 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020102 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020112 => { ES => $REPLICA, GS => $REPLICA },
	200020186 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020187 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020189 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020920 => { ES => $REPLICA, GS => $REPLICA },
	200020916 => { PL => $INCOMPLETE },
	200020921 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020924 => { ES => $REPLICA, GS => $REPLICA },
	200020925 => { ES => $REPLICA, GS => $REPLICA },
	200020926 => { ES => $REPLICA, GS => $REPLICA },
	200020928 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020964 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200020983 => { ES => $BROKEN },
	200021165 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200021166 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200021167 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200021171 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200220916 => { PL => $INCOMPLETE },
	200320191 => { GS => $INCOMPLETE },
	200321205 => { ES => $INCOMPLETE, GS => $INCOMPLETE, PL => $INCOMPLETE },
	200330134 => { PL => $BROKEN },
	200520298 => { ES => $REPLICA },
	200520458 => { ES => $BROKEN },
	200520677 => { RO => $BROKEN },
	200520679 => { RO => $BROKEN },
	200520681 => { RO => $BROKEN },
	200621024 => { ES => $INCOMPLETE, GS => $INCOMPLETE, PL => $BROKEN, },
	200721178 => { ES => $INCOMPLETE, GS => $INCOMPLETE, PL => $BROKEN, RO => $INCOMPLETE },
	200820259 => { ES => $INCOMPLETE, GS => $INCOMPLETE, PL => $BROKEN, RO => $INCOMPLETE },
	200820409 => { ES => $INCOMPLETE, GS => $INCOMPLETE, PL => $BROKEN, RO => $INCOMPLETE },
	200821077 => { ES => $INCOMPLETE, GS => $INCOMPLETE, PL => $BROKEN, RO => $INCOMPLETE },
	200920081 => { ES => $INCOMPLETE, GS => $INCOMPLETE, PL => $BROKEN, RO => $INCOMPLETE },
	200920827 => { GS => $INCOMPLETE },
	200920836 => { GS => $INCOMPLETE },
	200920857 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200920863 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	200920874 => { ES => $INCOMPLETE, GS => $INCOMPLETE, RO => $INCOMPLETE },
	200920885 => { ES => $INCOMPLETE, RO => $INCOMPLETE },
	201020429 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	201120259 => { ES => $INCOMPLETE, GS => $INCOMPLETE },
	201320971 => { GS => $BROKEN },
	201520079 => {BH => $INCOMPLETE},
	201520120 => {BH => $INCOMPLETE},
	201520168 => {BH => $INCOMPLETE},
	201520214 => {BH => $INCOMPLETE},
	201520307 => {BH => $INCOMPLETE},
#	201720620 => {PL => $INCOMPLETE, RO => $INCOMPLETE, ES => $INCOMPLETE},
);

our %MANUAL_FIX = (
	200120123 => { GS => 'Remove "2" throughout the file' },
	200520094 => {
		GS => 'Insert missing period for 15:35 penalty',
		PL => 'Edited string with 00:28 penalty',
	},
	200520305 => { GS => 'Insert missing period for 5:13 penalty' },
	200520233 => { GS => 'Add missing TBODY closing tag' },
	200620071 => { PL => 'Aligned period for event #1' },
	200620892 => { GS => 'Add missing TBODY closing tag' },
	201720463 => { PL => 'Fixed time -16:0-1' },
);
our %BROKEN_HEADERS = (
	200720295 => {
		location => 'Scottrade Center',
	},
);

our %SPECIAL_EVENTS = (
	200520312 => { 0  => 1 },
	201320971 => { 0  => 1 },
);

our %MISSING_EVENTS = (
	198930176 => [
		{
			type => 'GOAL',
			period => 5,
			time => '03:14',
			team1 => 'LAK',
			assist1 => 8446494,
			player1 => 8448566,
			strength => 'EV',
			shot_type => 'Unknown',
			distance => 999,
			location => 'Off',
		},
	],
	199020456 => [
		{
			type => 'PENL',
			period => 4,
			time => '03:41',
			player1 => 8448449,
			team1 => 'BUF',
			length => 2,
			penalty => 'Holding',
			strength => 'EV',
			location => 'Unk',
		},
	],
	199030242 => [
		{
			type => 'GOAL',
			period => 5,
			time => '04:48',
			team1 => 'EDM',
			player1 => 8448490,
			assist1 => 8451905,
			assist2 => 8449020,
			shot_type => 'Unknown',
			distance => 999,
			location => 'Off',
			strength => 'EV',
		},
	],
	199030243 => [
		{
			type => 'GOAL',
			period => 5,
			time => '00:48',
			team1 => 'EDM',
			player1 => 8451905,
			assist1 => 8448490,
			assist2 => 8448641,
			shot_type => 'Unknown',
			distance => 999,
			location => 'Off',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 5,
			time => '00:48',
			player1 => 8450941,
			team1 => 'LAK',
			length => 10,
			penalty => 'Misconduct',
			misconduct => 1,
			strength => 'EV',
			location => 'Unk',
		},
	],
	199130002 => [
		{
			type => 'PENL',
			period => 5,
			time => '00:48',
			player1 => 8450941,
			team1 => 'LAK',
			length => 10,
			penalty => 'Misconduct',
			misconduct => 1,
			strength => 'EV',
			location => 'Unk',
		},
	],
	199130117 => [
		{
			type => 'GOAL',
			time => '05:26',
			period => 5,
			team1 => 'MTL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8446208,
			assist1 => 8446167,
			assist2 => 8446415,
		},
	],
	199130163 => [
		{
			type => 'GOAL',
			time => '03:33',
			period => 5,
			team1 => 'STL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8448091,
			assist1 => 8445281,
			assist2 => 8451793,
		},
	],
	199230142 => [
		{
			type => 'GOAL',
			time => '14:50',
			period => 5,
			team1 => 'NYI',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8449742,
			assist1 => 8446823,
			assist2 => 8446838,
		},
	],
	199230144 => [
		{
			type => 'GOAL',
			time => '05:40',
			period => 5,
			team1 => 'NYI',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8446823,
			assist1 => 8448870,
			assist2 => 8446830,
		},
	],
	199230231 => [
		{
			type => 'GOAL',
			time => '03:16',
			period => 5,
			team1 => 'TOR',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8447206,
			assist1 => 8447187,
			assist2 => 8449009,
		},
	],
	199230232 => [
		{
			type => 'GOAL',
			time => '03:03',
			period => 5,
			team1 => 'STL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8445700,
			assist1 => 8446675,
			assist2 => 8448222,
		},
	],
	199230245 => [
		{
			type => 'GOAL',
			time => '06:31',
			period => 5,
			team1 => 'LAK',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8458020,
			assist1 => 8450941,
			assist2 => 8448569,
		},
	],
	199230312 => [
		{
			type => 'GOAL',
			time => '06:21',
			period => 5,
			team1 => 'MTL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8448719,
			assist1 => 8446303,
			assist2 => 8445739,
		},
	],
	199330136 => [
		{
			type => 'GOAL',
			time => '05:43',
			period => 7,
			team1 => 'BUF',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8447515,
			assist1 => 8458549,
			assist2 => 8450523,
		},
		{
			type => 'PENL',
			period => 6,
			time => '00:00',
			player1 => 8450678,
			team1 => 'BUF',
			length => 10,
			penalty => 'Misconduct',
			misconduct => 1,
			strength => 'EV',
			location => 'Unk',
		},
		{
			type => 'PENL',
			period => 6,
			time => '12:10',
			player1 => $BENCH_PLAYER_ID,
			team1 => 'NJD',
			length => 2,
			penalty => 'Too many men/ice',
			strength => 'EV',
			location => 'Unk',
			servedby => 8450825,
		},
	],
	199330167 => [
		{
			type => 'GOAL',
			time => '02:20',
			period => 5,
			team1 => 'VAN',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8455738,
			assist1 => 8445700,
			assist2 => 8445208,
		},
	],
	199330311 => [
		{
			type => 'GOAL',
			time => '15:23',
			period => 5,
			team1 => 'NJD',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8450825,
			assist1 => 8445977,
		},
		{
			type => 'PENL',
			period => 5,
			time => '04:14',
			player1 => 8451905,
			team1 => 'NYR',
			length => 2,
			penalty => 'Unsportsmanlike conduct',
			strength => 'EV',
			location => 'Unk',
		},
		{
			type => 'PENL',
			period => 5,
			time => '04:14',
			player1 => 8445461,
			team1 => 'NYR',
			length => 2,
			penalty => 'Roughing',
			location => 'Unk',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 5,
			time => '04:14',
			player1 => 8448772,
			team1 => 'NJD',
			length => 2,
			penalty => 'Unsportsmanlike conduct',
			location => 'Unk',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 5,
			time => '04:14',
			player1 => 8450825,
			team1 => 'NJD',
			length => 2,
			penalty => 'Roughing',
			location => 'Unk',
			strength => 'EV',
		},
	],
	199330313 => [
		{
			type => 'GOAL',
			time => '06:13',
			period => 5,
			team1 => 'NYR',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8449295,
		},
	],
	199330317 => [
		{
			type => 'GOAL',
			time => '04:24',
			period => 5,
			team1 => 'NYR',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8449295,
			assist1 => 8451905,
		},
	],
	199330325 => [
		{
			type => 'GOAL',
			time => '00:14',
			period => 5,
			team1 => 'VAN',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8444894,
			assist1 => 8445208,
			assist2 => 8448825,
		},
	],
	199430167 => [
		{
			type => 'GOAL',
			time => '01:54',
			period => 5,
			team1 => 'SJS',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8458537,
			assist1 => 8448669,
			assist2 => 8449163,
		},
	],
	199430323 => [
		{
			type => 'GOAL',
			time => '09:25',
			period => 5,
			team1 => 'DET',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8456870,
			assist1 => 8446789,
		},
	],
	199430325 => [
		{
			type => 'GOAL',
			time => '02:25',
			period => 5,
			team1 => 'DET',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8456887,
			assist1 => 8446788,
			assist2 => 8445730,
		},
	],
	199530124 => [
		{
			type => 'GOAL',
			time => '19:15',
			period => 7,
			team1 => 'PIT',
			strength => 'PP',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8449807,
			assist1 => 8458494,
			assist2 => 8448208,
		},
		{
			type => 'PENL',
			period => 5,
			time => '04:33',
			player1 => 8458179,
			team1 => 'PIT',
			length => 2,
			penalty => 'Roughing',
			location => 'Unk',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 5,
			time => '04:33',
			player1 => 8445575,
			team1 => 'WSH',
			length => 2,
			penalty => 'Roughing',
			location => 'Unk',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 6,
			time => '03:24',
			player1 => 8448380,
			team1 => 'PIT',
			length => 2,
			penalty => 'Slashing',
			location => 'Unk',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 6,
			time => '04:36',
			player1 => 8446181,
			team1 => 'WSH',
			length => 2,
			location => 'Unk',
			penalty => 'Tripping - Obstruction',
			strength => 'PP',
		},
		{
			type => 'PENL',
			period => 6,
			time => '19:17',
			player1 => 8456150,
			team1 => 'PIT',
			length => 2,
			penalty => 'Slashing',
			location => 'Unk',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 7,
			time => '17:21',
			player1 => 8448303,
			team1 => 'WSH',
			length => 2,
			penalty => 'Hooking',
			location => 'Unk',
			strength => 'EV',
		},
	],
	199530174 => [
		{
			type => 'GOAL',
			time => '10:02',
			period => 6,
			team1 => 'CHI',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8449751,
			assist1 => 8446217,
		},
	],
	199530215 => [
		{
			type => 'GOAL',
			time => '08:05',
			period => 5,
			team1 => 'FLA',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8447985,
			assist1 => 8451427,
			assist2 => 8448092,
		},
	],
	199530237 => [
		{
			type => 'GOAL',
			time => '01:15',
			period => 5,
			team1 => 'DET',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8452578,
			assist1 => 8456870,
		},
	],
	199530244 => [
		{
			type => 'GOAL',
			time => '04:33',
			period => 6,
			team1 => 'COL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8451101,
			assist1 => 8447363,
			assist2 => 8450817,
		},
		{
			type => 'PENL',
			period => 5,
			time => '19:38',
			player1 => 8448772,
			location => 'Unk',
			team1 => 'COL',
			length => 2,
			penalty => 'Roughing',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 5,
			time => '19:38',
			player1 => 8450561,
			location => 'Unk',
			team1 => 'CHI',
			length => 2,
			penalty => 'Cross checking',
			strength => 'PP',
		},
	],
	199530246 => [
		{
			type => 'GOAL',
			time => '05:18',
			period => 5,
			team1 => 'COL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8458544,
			assist1 => 8456770,
			assist2 => 8451101,
		},
	],
	199530414 => [
		{
			type => 'GOAL',
			time => '04:31',
			period => 6,
			team1 => 'COL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8448554,
		},
		{
			type => 'PENL',
			period => 5,
			time => '09:57',
			player1 => 8448772,
			team1 => 'COL',
			location => 'Unk',
			length => 2,
			penalty => 'Roughing',
			strength => 'EV',
		},
		{
			type => 'PENL',
			period => 5,
			time => '09:57',
			player1 => 8451427,
			team1 => 'FLA',
			length => 2,
			location => 'Unk',
			penalty => 'Slashing',
			strength => 'EV',
		},
	],
	199630114 => [
		{
			type => 'GOAL',
			time => '07:37',
			period => 6,
			team1 => 'MTL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8445739,
			assist1 => 8459442,
			assist2 => 8445734,
		},
	],
	199630153 => [
		{
			type => 'GOAL',
			time => '11:03',
			period => 5,
			team1 => 'CHI',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8458949,
			assist1 => 8446295,
		},
		{
			type => 'PENL',
			location => 'Unk',
			period => 5,
			time => '06:09',
			player1 => 8452353,
			team1 => 'CHI',
			length => 2,
			penalty => 'Holding',
			strength => 'EV',
		},
		{
			type => 'PENL',
			location => 'Unk',
			period => 5,
			time => '06:09',
			player1 => 8450561,
			team1 => 'CHI',
			length => 10,
			penalty => 'Misconduct',
			misconduct => 1,
			strength => 'EV',
		},
	],
	199630165 => [
		{
			type => 'GOAL',
			time => '00:22',
			period => 5,
			team1 => 'EDM',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8460496,
			assist1 => 8459429,
			assist2 => 8458963,
		},
	],
	199630242 => [
		{
			type => 'GOAL',
			time => '01:31',
			period => 6,
			team1 => 'DET',
			strength => 'PP',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8456887,
			assist1 => 8456870,
			assist2 => 8446789,
		},
		{
			type => 'PENL',
			period => 6,
			time => '01:03',
			player1 => 8446286,
			location => 'Unk',
			team1 => 'ANA',
			length => 2,
			penalty => 'Hooking',
			strength => 'EV',
		},
	],
	199630244 => [
		{
			type => 'GOAL',
			time => '17:03',
			period => 5,
			team1 => 'DET',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8451302,
			assist1 => 8458524,
			assist2 => 8452578,
		},
		{
			type => 'PENL',
			period => 5,
			time => '10:52',
			player1 => 8446789,
			location => 'Unk',
			team1 => 'DET',
			length => 2,
			penalty => 'Hi-sticking',
			strength => 'EV',
		},
	],
	199720894 => [
		{
			id => 999,
			type => 'GOAL',
			period => 4,
			time => '04:39',
			location => 'Off',
			team1 => 'PHI',
			shot_type => 'Unknown',
			strength => 'EV',
			player1 => 8457704,
			assist1 => 8456849,
			assist2 => 8459458,
		},
	],
	199730142 => [
		{
			type => 'GOAL',
			time => '00:54',
			period => 5,
			team1 => 'BOS',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8459249,
			assist1 => 8459439,
			assist2 => 8448484,
		},
	],
	199730143 => [
		{
			type => 'GOAL',
			time => '06:31',
			period => 5,
			team1 => 'WSH',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8456760,
			assist1 => 8449951,
			assist2 => 8445417,
		},
	],
	199730223 => [
		{
			type => 'GOAL',
			time => '01:24',
			period => 5,
			team1 => 'BUF',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8458976,
			assist1 => 8458347,
			assist2 => 8460579,
		},
	],
	199730243 => [
		{
			type => 'GOAL',
			time => '11:12',
			period => 5,
			team1 => 'DET',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8451302,
			assist1 => 8448669,
			assist2 => 8457063,
		},
	],
	199830122 => [
		{
			type => 'GOAL',
			time => '10:35',
			period => 5,
			team1 => 'BUF',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8459534,
			assist1 => 8458454,
			assist2 => 8456760,
		},
	],
	199830135 => [
		{
			type => 'GOAL',
			time => '14:45',
			period => 5,
			team1 => 'BOS',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8459156,
			assist1 => 8466138,
			assist2 => 8445621,
		},
	],
	199830154 => [
		{
			type => 'GOAL',
			time => '17:34',
			period => 6,
			team1 => 'DAL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8449893,
			assist1 => 8458494,
			assist2 => 8445423,
		},
		{
			type => 'PENL',
			period => 6,
			time => '07:46',
			player1 => 8459640,
			team1 => 'EDM',
			location => 'Unk',
			length => 2,
			penalty => 'Boarding',
			strength => 'EV',
		},
	],
	199830416 => [
		{
			type => 'GOAL',
			time => '14:51',
			period => 6,
			team1 => 'DAL',
			strength => 'EV',
			location => 'Off',
			shot_type => 'Unknown',
			distance => 999,
			player1 => 8448091,
			assist1 => 8459024,
			assist2 => 8449645,
		},
	],
	200210427 => [
		{
			'period' => 3,
			'team' => 'PHI',
			'str' => 'EV',
			'player2' => 8465200,
			'penalty' => 'Game Misconduct',
			'length' => '10',
			'id' => 143,
			'location' => 'Unk',
			'type' => 'PENL',
			'description' => '97 ROENICK, Charging (maj), 5 min, Served By 29 FEDORUK',
			'old' => 1,
			'team2' => 'TOR',
			'team1' => 'PHI',
			'time' => '07:33',
			'player1' => 8459078,
			servedby => 8462292,
			misconduct => 1,
		},
	],
);

our %MISSING_COACHES = (
	198720094 => [
		'Terry Simpson',
		'John Brophy',
	],
	198720190 => [
		"Terry O'Reilly",
		'Dan Maloney',
	],
	198820044 => [
		"Terry O'Reilly",
		'Pierre Page',
	],
	198820695 => [
		'George Armstrong',
		'Larry Pleau',
	],
	199220021 => [
		'John Muckler',
		'Paul Holmgren',
	],
	200220148 => [
		'Andy Murray',
		'Brian Sutter',
	],
	200320732 => [
		'Peter Laviolette',
		'Bob Hartley',
	],
);

our %MISSING_PLAYERS = (
	192330311 => [
		[
			{
				_id       => 8400001,
				position  => 'G',
				decision  => 'L',
				timeOnIce => '60:00',
				name      => 'CHARLIE REID',
				number    => 1,
				pim       => 0,
				goals     => 0,
				assists   => 0,
			},
		],
		[],
	],
	192330312 => [
		[
			{
				_id       => 8400001,
				position  => 'G',
				decision  => 'L',
				timeOnIce => '60:00',
				name      => 'CHARLIE REID',
				number    => 1,
				pim       => 0,
				goals     => 0,
				assists   => 0,
			},
		],
		[],
	],

);

=head1 NAME

Sport::Analytics::NHL::Errors - Hard fixes to errors in the NHL reports

=head1 SYNOPSYS

Hard fixes to errors in the NHL reports

Provides hard-coded corrections to the errors in the NHL reports or marks certain files as broken and unoperatable

This list shall expand as the release grows.

    use Sport::Analytics::NHL::Errors;
    # TBA

=cut

1;

=head1 AUTHOR

More Hockey Stats, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Errors>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Errors


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Errors>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Errors>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Errors>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Errors>

=back

