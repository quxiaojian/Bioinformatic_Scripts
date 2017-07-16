#!/usr/bin/perl -w
use strict;
use File::Find qw(find);
$|=1;

print "Please input your source dir: ";
chomp (my $source=<STDIN>);
my $pattern = ".fasta";
my @filenames;

find sub {
    if (/$pattern/){
        push @filenames,"$File::Find::name";
    }
}, $source;

open (my $output,">","alignment_many_directories.bat");
foreach (@filenames) {
	$_=~ s/\//\\/g;
	my $outdir=substr ($_,rindex($_,"\\")+1);
	print $output "megacc.exe -a muscle_align_nucleotide.mao -d ",$_," -f Fasta -o output\\$outdir\n";
}
close $output;
