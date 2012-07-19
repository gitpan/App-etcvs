package App::etcvs::Command::init;
{
  $App::etcvs::Command::init::VERSION = '0.01';
}

use v5.10;

use strict;
use warnings;

use App::Cmd -command;

use Git::Wrapper;

=head1 NAME

App::etcvs::Command::init - Initialize a new etcvs repository

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    $ etcvs init

=head1 DESCRIPTION

The C<init> command initializes a new etcvs repository.

=cut

sub abstract { 'initialize a new etcvs repository' }

sub usage_desc {
	return '%c init';
}

sub command_names { qw/init --init/ }

sub execute {
	my ($self, $opt, $args) = @_;

	my $git = Git::Wrapper -> new('./');
	$git -> init;

	say 'Initialize etcvs repository';
}

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of App::etcvs::Command::init
