package Sport::Analytics::NHL::DB;

use strict;
use warnings FATAL => 'all';
use v5.10.1;

use Data::Dumper;

use List::MoreUtils qw(any);

use Sport::Analytics::NHL::Vars   qw(
	$CURRENT_SEASON $CACHES $DEFAULT_STORAGE $DB $CONFIG
	$DEFAULT_MONGO_DB $MONGO_HOST $MONGO_PORT
);
use Sport::Analytics::NHL::Config qw($FIRST_SEASON);
use Sport::Analytics::NHL::Util   qw(:debug :tools log_mhs);

use if ! $ENV{HOCKEYDB_NODB} && $DEFAULT_STORAGE eq 'mongo', 'MongoDB';
use if ! $ENV{HOCKEYDB_NODB} && $DEFAULT_STORAGE eq 'mongo', 'BSON::OID';
use if ! $ENV{HOCKEYDB_NODB} && $DEFAULT_STORAGE eq 'mongo', 'MongoDB::MongoClient';

=head1 NAME

Sport::Analytics::NHL::DB - abstracting interface to MongoDB to store NHL reports.

=head1 SYNOPSYS

Interface to MongoDB in order to store the semi-structured NHL reports into it. Provides the database handle and most of the bulky database operations. Does not subclass MongoDB - the handle is stored in the class's object.

    use Sport::Analytics::NHL::DB;
    my $db = Sport::Analytics::NHL::DB->new();
    my $team_id = $db->get_collection('schedule');

=head1 EXPORTS

Two functions are exported, beside the OO interface:

=over 2

=item build_date_query()

Builds date query for a given date, season or game_id. Produces a range for start_season and stop_season.

 Arguments: the object initialization hashref
 [optional] the extra overriding options hashref
 Returns: a query hashref

=item dump_query()

Dumps the Mongo query in a way that can be pasted into Mongo console

 Arguments: the list of queries
 Returns: void

=back

=head1 Internal Functions

=over 2

=item convert_field_to_number_list($query, $opts, $field)

Ensures that option specified in $opts->{$field} is numeric and stores it in $query->{$field}

=item get_default_id_field($collection_name)

Gets default id field for a collection. The logic works as following:

 For an event collection returns 'event_id'
 For a 'plurals' collection chops the 's' off
 and then returns the collection name plus suffix '_id'

=back

=head1 METHODS

=over 2

=item CLASS->new($config)

Constructor. Connects to the MongoDB and stores the handle to the database. This is not a subclass of Mongo, all the
database communications happen via $self->{dbh}. The configuration fields in the hashref are: MONGO_DB, MONGO_HOST, MONGO_PORT

 Arguments: the configuration hashref
 Returns: the blessed db object

=item $db->get_collection($collection)

Gets the handle to the Mongo collection and caches it.

 Arguments: the collection name
 Returns: the handle to the collection

=item $db->query($method, $collection_name, $query, $opts)

Executes a query against a MongoDB

 Arguments: the method to query with (usually find or find_one)
            collection name
 [optional] the query filter
 [optional] postprocessing options hashref, e.g. limit or sort,
   or call for all values.

 Returns: an array of values (for all), or a Mongo Cursor.

=item $db->find()

Shortcut to a query via find

=item $db->pick()

Shortcut to a query via find_one

=item $db->insert($collection_name, $data)

Wrapper for inserting data into Mongo.

 Arguments: collection name
            data to insert
 [optional] global configuration hashref (e.g. from the calling object)
 [optional] configuration hashref for this particual call

=back

=cut

our $DEFAULT_HOST = '127.0.0.1';
our $DEFAULT_PORT = 27017;

use parent 'Exporter::Tiny';

our @EXPORT = qw(build_date_query dump_query);

sub new ($;$) {

	my $class  = shift;
	my $config = shift;

	die "Mongo DB support has been explicitly disabled"
		if $ENV{HOCKEYDB_NODB} || $DEFAULT_STORAGE ne 'mongo';
	my $self = {};
	my $database = $config->{MONGO_DB}   || $ENV{HOCKEYDB_DBNAME} || $DEFAULT_MONGO_DB;
	my $host     = $config->{MONGO_HOST} || $MONGO_HOST || $CONFIG->{mongo_host} || $DEFAULT_HOST;
	my $port     = $config->{MONGO_PORT} || $MONGO_PORT || $CONFIG->{mongo_port} || $DEFAULT_PORT;
	$self->{client} = MongoDB::MongoClient->new(
		host                  => sprintf(
			"mongodb://%s:%d", $host, $port
		), connect_timeout_ms => 60000,
		$CONFIG->{mongo_user} ? (
			username => $CONFIG->{mongo_user},
			password => $CONFIG->{mongo_pass},
		) : (),
	);
	$self->{dbh} = $self->{client}->get_database($database);
	$DB = $self;
	$ENV{HOCKEYDB_DBNAME} = $database;
	verbose "Using Mongo database $database";
	bless $self, $class;
	$self;
}

sub get_collection ($$) {

	my $self = shift;
	my $collection = shift;

	$CACHES->{collections}{$collection} ||= $self->{dbh}->get_collection($collection);
	$CACHES->{collections}{$collection};
}

sub convert_field_to_number_list ($$$) {

	my $query = shift;
	my $opts  = shift;
	my $field = shift;

	my $values = [ map(
		$_+0,
		@{ref($opts->{$field}) ? $opts->{$field} : [ $opts->{$field} ] }
	)];
	$query->{$field} = { '$in' => $values };
}

sub build_date_query ($;$) {

	my $data_opts = shift || {};
	my $extra_opts = shift || {};

	my $opts = merge_hashes($data_opts, $extra_opts);

	my $query = {};

	for (qw(game_id date season)) {
		if ($opts->{$_}) {
			convert_field_to_number_list($query, $opts, $_);
			return $query;
		}
	}
	if ($opts->{start_season} || $opts->{stop_season}) {
		$opts->{start_season} ||= $FIRST_SEASON;
		$opts->{stop_season}  ||= $CURRENT_SEASON;
		$query->{season} = {
			'$in' => [ $opts->{start_season} .. $opts->{stop_season} ],
		};
	}
	else {
		die "Error: no date field present";
	}
	$query;
}

sub dump_query (@) {

	my @caller = ();
	my $c = 3;
	@caller = caller($c) while $c--;

	my $filename = $caller[1];
	my $line = $caller[2];

	{
		local $Data::Dumper::Varname = 'MONGO';
		$Data::Dumper::Deepcopy ||= 1;
		print "Mongo debug called in $filename: $line\n";
		for (@_) {
			my $q = Dumper $_;
			$q =~ s/\=\>/\:/g;
			$q =~ s/\'(\d+?)\'/$1/ge;
			$q =~ s/\$MONGO\d+ = //;
			$q =~ s/\};/\}/;
			print $q;
		}
	}
	1;
}

sub query ($$$$$) {

	my $self            = shift;
	my $method          = shift;
	my $collection_name = shift;
	my $query           = shift || {};
	my $opts            = shift || {};

	dump_query($query) if $ENV{HOCKEYDB_DEBUG};
	my $collection = $self->get_collection($collection_name);
	my $result = $collection->$method($query);
	if (ref $result eq 'MongoDB::Cursor') {
		$result->$_($opts->{$_}) for grep {$opts->{$_}} qw(limit sort);
		return $opts->{all} ? $result->all() : $result;
	}
	else {
		return $result;
	}
}

sub find ($$$$) { shift->query('find',     @_); }
sub pick ($$$$) { shift->query('find_one', @_); }

sub get_default_id_field ($) {

	my $collection_name = shift;

	return 'event_id' if $collection_name =~ /^[A-Z]/;
	chop $collection_name if $collection_name =~ /s$/;
	"${collection_name}_id";
}

sub insert ($$$;$$) {

	my $self = shift;
	my $collection_name = shift;
	my $data = shift;
	my $data_opts = shift || {};
	my $extra_opts = shift || {};

	my $opts = merge_hashes($data_opts, $extra_opts);

	my $collection = ref $collection_name
		? $collection_name
		: $self->get_collection($collection_name);
	$data = [$data] if ref $data ne 'ARRAY';
	my $now = time;
	$_->{inserted} = $now for @{$data};
	my $id_field = $opts->{id_field} || get_default_id_field($collection_name);
	if ($opts->{force}) {
		my @ids = map($_->{$id_field}, @{$data});
		verbose("Removing items with $id_field " . join(',', @ids));
		log_mhs('DB', "Removed " . scalar(@ids) . " items from $collection_name", 'notice');
		$collection->delete_many({$id_field => {'$in' => \@ids}});
	}
	my $found = any { $_->{key}{$id_field} } $collection->indexes->list->all();
	$collection->indexes->create_one( [ $id_field => 1 ], { unique => 1 } ) if $found;
	$collection->insert_many($data);
	log_mhs('DB', "Inserted " . scalar(@{$data}) . " items into $collection_name", 'notice');
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::DB>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::DB


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::DB>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::DB>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::DB>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::DB>

=back
