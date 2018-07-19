#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Cwd "abs_path";
use File::Find;
$|=1;

my $global_options=&argument();
my $path=&default("test","path");
my $dirname=&default("dirnames.txt","output");

my @folders;
my $abs_path=abs_path($path);
find(\&target,$abs_path);
sub target{
    if (-d $File::Find::name){
        push @folders,"$File::Find::name";
    }
    return;
}
open(my $output,">",$dirname);
foreach my $i (@folders) {
	print $output "$i\n";
}
close $output;


########################################
##subroutines
########################################

sub argument{
	my @options=("help|h","path|p:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'path'}){
		print "***ERROR: No path directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output filename is assigned!!!\n";
		exec ("pod2usage $0");
	}
	return \%options;
}

sub default{
	my ($default_value,$option)=@_;
	if(exists $global_options->{$option}){
		return $global_options->{$option};
	}
	return $default_value;
}


__DATA__

=head1 NAME

    get_multiple_layers_directory_names.pl

=head1 COPYRIGHT

    copyright (C) 2018 Xiao-Jian Qu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION

    get_multiple_layers_directory_names

=head1 SYNOPSIS

    get_multiple_layers_directory_names.pl -p -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-p -path]         required: (default: test) input path directory.
    [-o -output]       required: (default: dirnames.txt) output file name.

=cut
