use strict;
use warnings;

use File::Find;
use File::Basename qw(dirname);
use File::Spec::Functions qw(abs2rel canonpath catfile);


use v5.10;

my $Base = '/Users/brian/Dev';

{
if( my $target = readlink($Base) ) {
	$Base = $target;
	redo;
	}
}

my $callback = sub {
	my( $dir ) = @_;

	return unless -d $dir;

	my @directories = 
		map { abs2rel( dirname( $_ ), $base ) } 
		keys %files;

	if( -e catfile( $Base, $dir, '.git' ) ) {
		my( $branch ) = `(cd $dir; git status 2>&1)` =~ m/\A# On branch (\S+)/;
		say "\tbranch: $branch";
		}
	else {
		say "\tNot a git directory!";
		}


	};


sub get_directory_list {
	my( $base ) = @_;

	my %files;
	my @build_files = qw(Makefile.PL Build.PL) );

	my( $wanted, $reporter ) = find_by_name( $callback, $file, @build_files );
	File::Find::find( $wanted, $base );
	}

sub find_by_name {
	my( $callback, @names ) = @_;
	my %hash  = map { $_, 1 } @names;
	my @files = ();
	
	sub { 
		my $cp = canonpath( $File::Find::name );
		if( exists $hash{$_} ) {
			push @files, $cp;
			$callback->( $cp )
			}
		}
	}
