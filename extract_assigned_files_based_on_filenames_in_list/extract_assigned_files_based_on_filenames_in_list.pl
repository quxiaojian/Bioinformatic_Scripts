#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;
use File::Copy;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $source=&default("input","input");
my $pattern=&default(".nex","pattern");
my $list=&default("list.txt","list");
my $destination=&default("output","output");

my $osname=$^O;
if ($osname eq "MSWin32") {
	system("del/f/s/q $destination") if (-e $destination);
}elsif ($osname eq "cygwin") {
	system("rm -rf $destination") if (-e $destination);
}elsif ($osname eq "linux") {
	system("rm -rf $destination") if (-e $destination);
}elsif ($osname eq "darwin") {
	system("rm -rf $destination") if (-e $destination);
}
mkdir ($destination) if (!-e $destination);

my @filenames;
find(\&target,$source);
sub target{
    if (/$pattern/){
        push @filenames,"$File::Find::name";
    }
    return;
}

my %hash;
foreach (@filenames) {
	my $name=$_;
	$name=substr($name,rindex($name,"/")+1);
	$hash{$name}=1;
}

open (my $input,"<",$list);
while (<$input>){
	chomp;
	if (exists $hash{$_}){
		$hash{$_}++;
		copy ("$source/$_","$destination/$_");
	}
}
close $input;

open (my $output,">","remaining.txt");
foreach (sort keys %hash){
	print $output "$_\n" if ($hash{$_}==1);
}
close $output;


##function
sub argument{
	my @options=("help|h","input|i:s","pattern|p:s","list|l:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'pattern'}){
		print "***ERROR: No suffix pattern is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'list'}){
		print "***ERROR: No list filename is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output directory is assigned!!!\n";
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

    extract_assigned_files_based_on_filenames_in_list.pl

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

    extract assigned files based on filenames in list

=head1 SYNOPSIS

    extract_assigned_files_based_on_filenames_in_list.pl -i -p -l -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory.
    [-p -pattern]      required: (default: .nex) suffix pattern.
    [-l -list]         required: (default: list.txt) list filename.
    [-o -output]       required: (default: output) output directory.

=cut
