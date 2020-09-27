package Sport::Analytics::NHL::Util;

use strict;
use warnings FATAL => 'all';
use v5.10.1;

use Data::Dumper;
use File::Basename;
use File::Path qw(mkpath);

use Sport::Analytics::NHL::Vars qw(:local_config);

use Date::Parse;

use parent 'Exporter::Tiny';

=head1 NAME

Sport::Analytics::NHL::Util - Simple system-independent utilities

=head1 SYNOPSIS

Provides simple system-independent utilities. For system-dependent utilities see Sports::Analytics::NHL::Tools .

  use Sport::Analytics::NHL::Util qw(:debug :file);
  debug "This is a debug message";
  verbose "This is a verbose message";
  my $content = read_file('some.file');
  write_file($content, 'some.file');
  $config = read_config('some.config');

By default nothing is exported. You can import the functions either by name, or by the tags listed below, or by tag ':all'.

:debug     : debug verbose gamedebug timedebug eventdebug gameverbose timeverbose eventverbose dumper dumperr

:file      : read_file write_file read_config

:tools     : merge_hashes

=head1 FUNCTIONS

=over 2

=item C<debug>

Produces message to the STDERR if the DEBUG level is set ($ENV{HOCKEYDB_DEBUG})

=item C<verbose>

Produces message to the STDERR if the VERBOSE ($ENV{HOCKEYDB_VERBOSE})or the DEBUG level are set.

=item C<get_gamedebug>

Prepares the game information for gameverbose/gamedebug

=item C<get_eventdebug>

Prepares the event information for eventverbose/eventdebug

=item C<timedebug>

Produces debug message to the STDERR with time data prepended

=item C<timeverbose>

Produces verbose message to the STDERR with time data prepended

=item C<gamedebug>

Produces debug message to the STDERR with game data prepended

=item C<gameverbose>

Produces verbose message to the STDERR with game data prepended

=item C<eventdebug>

Produces debug message to the STDERR with event data prepended

=item C<eventverbose>

Produces verbose message to the STDERR with event data prepended

=item C<dumper>

Dumps a variable in an orderly, sorted way, either via Data::Dumper, or (for HTML::Element) via dump() method.

 Arguments: variables to dump
 Returns: void

=item C<dumperr>

Performs dumper() <q.v.> to STDERR

=item C<read_file>

Reads a file into a scalar

 Arguments: the filename
 Returns: the scalar with the filename contents

=item C<write_file>

Writes a file from a scalar, usually replacing the non-breaking space with regular space

 Arguments: the content scalar
            the filename
 Returns: the filename written

=item C<read_tab_file>

Reads a tabulated file into an array of arrays

 Arguments: the tabulated file
 Returns: array of arrays with the data

=item C<read_config>

Utility function that reads the sharepoint configuration file of whitespace separated values.

 Arguments: the configuration file
 Returns: Hash of configuration parameters and their values.

=cut

=item C<merge_hashes>

Merges two hashes into one.

 Arguments: two hashrefs
 Returns: the merged hashref. The second one is the winner
  if keys coincide.

=item C<log_mhs>

Logs a message into a file by severity

 Arguments: The logging facility string
            The message string
 [optional] The severity string (debug is ignored unless HOCKEYDB_DEBUG env is set)
                                (info is ignored unless HOCKEYDB_VERBOSE env is set)
            info is the default level.
 [optional] The log file. $LOG_DIR/$0.log is the default value.
 Returns: the log filename

=back

=cut

my @debug = qw(
	debug verbose gamedebug gameverbose eventdebug eventverbose timedebug timeverbose
	dumper dumperr
);
my @file = qw(read_file read_tab_file write_file read_config);
my @tools = qw(merge_hashes);
my @time = qw();
my @logs = qw(log_mhs);
our @EXPORT_OK = (
	@debug, @file, @tools, @time, @logs
);

our %EXPORT_TAGS = (
	debug => [ @debug ],
	file  => [ @file ],
	tools => [ @tools ],
	time  => [ @time ],
);

my ($package, $file, $line);

sub debug ($) {
	my $message = shift;
	print STDERR "$message\n" if $ENV{HOCKEYDB_DEBUG};
}

sub verbose ($) {
	my $message = shift;
	print STDERR "$message\n" if $ENV{HOCKEYDB_VERBOSE} || $ENV{HOCKEYDB_DEBUG};
}

sub get_gamedebug ($$) {

	my $game   = shift;
	my $prefix = shift;

	$game->{teams}
		? "$prefix: $game->{_id} $game->{date} $game->{teams}[0]{name} $game->{teams}[0]{score} - $game->{teams}[1]{score} $game->{teams}[1]{name}"
		: "$prefix: $game->{game_id} $game->{away} @ $game->{home}";
}

sub gamedebug ($;$) {

	my $game   = shift;
	my $prefix = shift || 'gamedebug';

	debug get_gamedebug($game, $prefix);
}

sub gameverbose ($;$) {

	my $game   = shift;
	my $prefix = shift || 'gamedebug';

	verbose get_gamedebug($game, $prefix);
}

sub get_eventdebug ($$) {

	my $event  = shift;
	my $prefix = shift;

	sprintf "%-30s %d \@%-5s", $prefix, $event->{_id}, $event->{ts};
}

sub eventdebug ($;$) {

	my $event = shift;
	my $prefix = shift || 'eventdebug';

	debug get_eventdebug($event, $prefix);
}

sub eventverbose ($;$) {

	my $game   = shift;
	my $prefix = shift || 'gamedebug';

	verbose get_eventdebug($game, $prefix);
}

sub timedebug ($;$) {

	my $message = shift;
	my $timestamp = time;

	debug "$timestamp $message";
}

sub timeverbose ($;$) {

	my $message = shift;
	my $timestamp = time;

	verbose "$timestamp $message";
}

sub dumper (@) {

	my ($_package, $_file, $_line) = caller;

	$package ||= $_package;
	$file    ||= $_file;
	$line    ||= $_line;

	verbose "Called in $file: $line\n";
	$Data::Dumper::Trailingcomma ||= 1;
	$Data::Dumper::Deepcopy      ||= 1;
	$Data::Dumper::Sortkeys      ||= 1;
	$Data::Dumper::Deparse       ||= 1;
	my $is_ref = ref $_[0];
	if ($is_ref && $is_ref =~ /HTML::Element/) {
		print $_[0]->dump;
	}
	else {
		print Dumper @_;
	}
	undef $package, $file, $line;
}

sub dumperr (@) {

	($package, $file, $line) = caller;

	select STDERR;
	dumper(@_);
	select STDOUT;
}

sub read_file ($;$) {

	my $filename = shift;
	my $no_strip = shift || 0;

	my $content;
	debug "Reading $filename ...";
	open(my $fh, '<', $filename) or die "Couldn't read file $filename: $!";
	{
		local $/ = undef;
		$content = <$fh>;
	}
	close $fh;
	$content =~ s/\xC2\xA0/ /g unless $no_strip;
	$content;
}

sub read_tab_file ($) {

	my $filename = shift;
	my $table = [];

	debug "Reading tabulated $filename ...";
	open(my $fh, '<', $filename) or die "Couldn't read file $filename: $!";
	while (<$fh>) {
		next unless /\S/;
		chomp;
		my @row = split(/\t/);
		push(@{$table}, [@row]);
	}
	close $fh;
	$table;
}

sub write_file ($$;$) {

	my $content  = shift;
	my $filename = shift;
	my $no_strip = shift || 1;

	debug "Writing $filename ...";
	mkpath(dirname($filename)) unless -d dirname($filename);
	$content =~ s/\xC2\xA0/ /g if $no_strip == -1;
	open(my $fh, '>', $filename) or die "Couldn't write file $filename: $!";
	binmode $fh, ':utf8';
	print $fh $content;
	close $fh;
	$filename;
}

sub read_config ($) {

	my $config_file = shift;

	my $config      = {};
	open(my $conf_fh, '<', $config_file) or return 0;
	while (<$conf_fh>) {
		next if /^\#/ || ! /\S/;
		s/^\s+//; s/\s+$//;
		my ($key, $value) = split(/\s+/, $_, 2);
		unless ($value) {
			$config->{$key} = undef;
			next;
		}
		chomp $value;
		while ($value =~ /\\$/) {
			my $extra_value = <$conf_fh>;
			next if $extra_value =~ /^\#/ || $extra_value !~ /\S/;
			$extra_value =~ s/^\s+//; $extra_value =~ s/\s+$//;
			chop $value;
			$value =~ s/\s+$//;
			$value .= " $extra_value";
		}
		$config->{$key} = $value;
	}
	close $conf_fh;
	$config;
}

sub merge_hashes ($$) {

	my $h1 = shift; my $h2 = shift;
	my $h = {};

	for my $h12 ($h1, $h2) {
		for my $k (keys %{$h12}) {
			$h->{$k} = $h12->{$k};
		}
	}
	$h;
}

sub log_mhs ($$;$$$) {

	my $facility = shift;
	my $message  = shift;
	my $severity = shift || 'info';
	my $filename = shift || undef;

	return if $severity eq 'debug' && ! $ENV{HOCKEYDB_DEBUG};
	return if $severity eq 'info'  && ! $ENV{HOCKEYDB_DEBUG} && ! $ENV{HOCKEYDB_VERBOSE};
	$filename ||= $LOG_DIR . "/$0.log";
	my $dir = dirname($filename);
	mkpath($dir) unless -d $dir;
	open(my $fh, '>>', $filename) or die "Couldn't open $filename for logging: $!";
	printf $fh "%s [%s] <%s>: %s\n", scalar(localtime), $severity, $facility, $message;
	close $fh;
	$filename;
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Util>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Util


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Util>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Util>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Util>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Util>

=back
