#!/usr/bin/perl -w
use strict;
$|=1;

print "Please input your source dir: ";
chomp (my $source=<STDIN>);
opendir (my $indir,$source);
my @filenames=grep /.+\.fasta$/,readdir $indir;
open (my $output,">","alignment_one_directory.bat");
foreach (@filenames) {
	print $output "megacc.exe -a muscle_align_nucleotide.mao -d ","$source\\$_"," -f Fasta -o output\\$_\n";
}
close $indir;
close $output;
