package Sport::Analytics::NHL::Script;

use strict;
use warnings FATAL => 'all';
use v5.10;

use Sport::Analytics::NHL::Usage qw(gopts);

use Syntax::Collector q/
  use strict 0;
  use warnings 0;
  use feature 0 ':5.10';
/;

=head1 NAME

Sport::Analytics::NHL::Script - Base framework for all project's scripts

=head1 SYNOPSIS

Base framework for all project's scripts. Provides a call to Usage::gopts for easier life.

 package do_something;
 use parent 'Sport::Analytics::NHL::Script';

 sub run ($) { really_do_something }

 package main;
 my $app = do_something->new('Does something');
 $app->run();

=head1 METHODS

=over 2

=item C<new>

Constructor. Creates an application object and tests/sets its runtime options.

 Arguments: the class
            the string what the program does
 [optional] the arref of options used from C<Sport::Analytics::NHL::Usage>
 [optional] the arref of arguments used

=item C<run>

MUST be overridden. Will die if not.

=back

=cut

sub new ($$;$$) {

	my $class        = shift;
	my $what_it_does = shift;
	my $accepts_opts = shift || [];
	my $accepts_args = shift || [];

	my $opts = gopts($what_it_does, $accepts_opts, $accepts_args);
	bless $opts, $class;
}

sub run ($$) {

	die "Override me";
}

1;

=head1 AUTHOR

Roman Parparov, C<< <contact at morehockeystats.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<contact at morehockeystats.com>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Sport::Analytics::NHL::Script>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Sport::Analytics::NHL::Script


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Sport::Analytics::NHL::Script>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Sport::Analytics::NHL::Script>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Sport::Analytics::NHL::Script>

=item * Search CPAN

L<https://metacpan.org/release/Sport::Analytics::NHL::Script>

=back
