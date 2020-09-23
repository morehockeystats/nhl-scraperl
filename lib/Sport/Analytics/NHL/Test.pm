package Sport::Analytics::NHL::Test;

use strict;
use warnings FATAL => 'all';
use v5.10.1;

use parent 'Exporter::Tiny';

=head1 NAME

Sport::Analytics::NHL::Test - Utilities to test NHL reports data.

=head1 SYNOPSIS

Utilities to test NHL report data

Currently a placeholder

=head1 GLOBAL VARIABLES

 The behaviour of the tests is controlled by several global variables:
 * $TEST_COUNTER - contains the number of the current test in Curr_Test field and the number of passes/fails in Test_Results.

=cut

our $TEST_COUNTER = 0;
our @EXPORT_OK = qw($TEST_COUNTER);
1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

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
