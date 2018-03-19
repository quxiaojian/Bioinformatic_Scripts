#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $input_filename=&default("input.txt","input");
my $column_number=&default("1","column");
$column_number=eval($column_number);
my $output_dirname=&default("output","output");
my $osname=$^O;
if ($osname eq "MSWin32") {
	system("del/f/s/q $output_dirname") if (-e $output_dirname);
}elsif ($osname eq "cygwin") {
	system("rm -rf $output_dirname") if (-e $output_dirname);
}elsif ($osname eq "linux") {
	system("rm -rf $output_dirname") if (-e $output_dirname);
}elsif ($osname eq "darwin") {
	system("rm -rf $output_dirname") if (-e $output_dirname);
}
mkdir ($output_dirname) if (!-e $output_dirname);

open (my $input,"<",$input_filename);
my $i=0;
while (my $row=<$input>) {
	$i++;
	#chomp $row;
	$row=~ s/\r|\n//g;
	my @row=split /\t/,$row;
	my $output_filename;
	if (exists $row[$column_number-1]) {
		$output_filename=$row[$column_number-1].".txt";
	}elsif (!exists $row[$column_number-1]) {
		#$output_filename="null_$i.txt";
		$output_filename="null.txt";
	}
	open (my $output,">>","$output_dirname/$output_filename");
	print $output "$row\n";
	close $output;
}
close $input;


###function###
sub argument{
	my @options=("help|h","input|i:s","column|c:i","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input filename are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'column'}){
		print "***ERROR: No column number are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output directory name are assigned!!!\n";
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

    split_file_based_on_same_content_in_column.pl

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

    split file based on same content in column

=head1 SYNOPSIS

    split_file_based_on_same_content_in_column.pl -i -c -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -input]          input filename (default: input.txt).
    [-c -column]         column number (default: 1).
    [-o -output]         output directory name (default: output).

=cut
