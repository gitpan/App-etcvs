package App::etcvs::Command::restore;
{
  $App::etcvs::Command::restore::VERSION = '0.01';
}

use v5.10;

use strict;
use warnings;

use App::Cmd -command;

use Try::Tiny;

use Term::UI;
use Term::ReadLine;

use File::Basename;

use Git::Wrapper;

use IPC::System::Simple qw(capture $EXITVAL);

=head1 NAME

App::etcvs::Command::restore - Restore a configuration file

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    $ etcvs restore <file>

=head1 DESCRIPTION

The C<restore> command restore the given file from the etcvs repository.

=cut

sub abstract { 'restore a configuration file' }

sub usage_desc {
	return '%c restore <file>';
}

sub command_names { qw/restore --restore/ }

sub opt_spec {
	return (
		[ 'all|a',      'restore all the already known files'      ],
		[ 'prefix|p=s', 'the target directory (default \'$HOME\')' ],
		[ 'sudo|s',     'restore using sudo (use with caution)'    ]
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
		_restore_file($git, $args -> [0], $opt);
	}
}

sub _restore_file {
	my ($git, $file, $opt) = @_;

	my $dest = $opt -> {'prefix'} . "/$file";
	my $base = dirname($dest);

	my $term = Term::ReadLine -> new('etcvs');

	try {
		$git -> RUN('ls-files', $file, '--error-unmatch');
	} catch {
		die "Unknown file '$file'\n";
	};

	my $reply = $term -> ask_yn(
		prompt  => "Do you really want to restore '$dest'?",
		default => 'n'
	);

	die "Restore aborted\n"
		unless $reply;

	if ($opt -> {'sudo'}) {
		try { capture('sudo', 'mkdir', '-p', $base) };
		die "Restore failed: cannot create '$base'\n" if $EXITVAL;

		try { capture('sudo', 'cp', $file, $base) };
		die "Restore failed: cannot copy to '$base'\n" if $EXITVAL;
	} else {
		try { capture('mkdir', '-p', $base) };
		die "Restore failed: cannot create '$base'\n" if $EXITVAL;

		try { capture('cp', $file, $base) };
		die "Restore failed: cannot copy to '$base'\n" if $EXITVAL;
	}

	say "Restored file '$dest'";
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

1; # End of App::etcvs::Command::restore
