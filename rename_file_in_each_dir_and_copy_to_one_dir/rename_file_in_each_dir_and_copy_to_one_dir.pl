#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;
use File::Copy;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","indir");
my $match=&default(".fasta","match");
my $outdir=&default("output","outdir");
my $osname=$^O;
if ($osname eq "MSWin32") {
	system("del/f/s/q $outdir") if (-e $outdir);
}elsif ($osname eq "cygwin") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "linux") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "darwin") {
	system("rm -rf $outdir") if (-e $outdir);
}
mkdir ($outdir) if (!-e $outdir);

my @filenames;
find(\&target,$indir);
sub target{
    if (/$match/){
        push @filenames,"$File::Find::name";
    }
    return;
}

while (@filenames) {
	my $name1=shift @filenames;#trinity/Aaus/Trinity.fasta
	my $name2=substr($name1,0,rindex($name1,"\/"));#trinity/Aaus
	my $name3=substr($name2,(rindex($name2,"\/")+1));#Aaus
	my $name4=substr($name1,(rindex($name1,"\/")+1));#Trinity.fasta
	my $name5=$name1;
	$name5=~ s/$name4/$name3$match/;#trinity/Aaus/Aaus.fasta
	rename ("$name1","$name5");
	copy ("$name5","$outdir/$name3$match");
}


###function###
sub argument{
	my @options=("help|h","indir|i:s","match|m:s","outdir|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'indir'}){
		print "***ERROR: No input directory are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'match'}){
		print "***ERROR: No match are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'outdir'}){
		print "***ERROR: No output directory are assigned!!!\n";
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

    rename_file_in_each_dir_and_copy_to_one_dir.pl

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

    rename file in each dir and copy to one dir

=head1 SYNOPSIS

    rename_file_in_each_dir_and_copy_to_one_dir.pl -i -m -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          input directory (default: input).
    [-m -match]          match pattern for your filename (default: .fasta).
    [-o -outdir]         output directory (default: output).

=cut
