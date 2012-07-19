package App::etcvs::Command::import;
{
  $App::etcvs::Command::import::VERSION = '0.01';
}

use v5.10;

use strict;
use warnings;

use App::Cmd -command;

use Try::Tiny;

use File::Path qw(make_path);
use File::Copy;
use File::Basename;

use Git::Wrapper;

=head1 NAME

App::etcvs::Command::import - Import a configuration file

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    $ etcvs import fstab

=head1 DESCRIPTION

The C<import> command imports a configuration file into the repository.

=cut

sub abstract { 'import a configuration file' }

sub usage_desc {
	return '%c import <file>';
}

sub command_names { qw/import --import/ }

sub opt_spec {
	return (
		[ 'all|a',       'import all the already known files'       ],
		[ 'prefix|p=s',  'the source directory (default \'$HOME\')' ],
		[ 'message|m=s', 'commit message'                           ]
	);
}

sub execute {
	my ($self, $opt, $args) = @_;

	my $git = Git::Wrapper -> new('./');

	$opt -> {'prefix'} = $ENV{'HOME'}
		unless $opt -> {'prefix'};

	if ($opt -> {'all'}) {
		my @files = $git -> RUN('ls-files');

		foreach my $file (@files) {
			_import_file($git, $file, $opt);
		}
	} else {
		_import_file($git, $args -> [0], $opt);
	}
}

sub _import_file {
	my ($git, $file, $opt) = @_;

	my $src  = $opt -> {'prefix'} . "/$file";
	my $base = dirname($file);

	make_path($base) or die "Import failed: $!\n"
		unless (-d $base);

	copy($src, $base) or
		die "Import failed: $!\n";

	my $message = try {
		$git -> RUN('ls-files', $file, '--error-unmatch');

		return $opt -> {'message'};
	} catch {
		return "initial import of '$src'";
	};

	try {
		$git -> add($file);

		$message = "import of '$src'"
			unless $message;

		$git -> commit({ message => $message });

		say "Imported file '$src'";
	} catch {
		say "Nothing to do for '$src'";
	}
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

1; # End of App::etcvs::Command::import
