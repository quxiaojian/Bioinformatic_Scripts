#!/usr/bin/perl
use strict;

open (my $genename,"<","genename.txt");
chomp (my @names=<$genename>);
close $genename;

open (my $file,"<","PCG_M.fasta");
my $outdir="output";
system ("rm -rf output") if (-e $outdir);
system ("mkdir output") if (! -e $outdir);
my $count=0;
my $update=0;
seek ($file,0,0);

while (chomp (my $header=<$file>) && chomp (my $sequence=<$file>)) {
	foreach my $name (@names) {
		if ($header=~ m/$name/) {
			open (my $fh,">>","$outdir/$name.fasta");
			print $fh "$header\n$sequence\n";
			close $fh;
		}
	}
}
close $file;
