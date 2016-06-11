#!/usr/bin/perl -w
use strict;

my $indir="input";
my $outdir="output";
system ("mkdir $outdir") if (! -e $outdir);
my $i=0;
my $infile;
my $outfile;

while (defined ($infile=glob ($indir."/*.fasta"))){
	printf ("(%d)\tNow processing file => %s\t",++$i,$infile);
	$outfile=$outdir."/".substr ($infile,rindex ($infile,"/")+1);
	open (my $input,"<",$infile);
	open (my $output,">",$outfile);

	my %hash;
	while (<$input>) {
		if (not $hash{$_}++){
			print $output $_;
		}
	}

	close $input;
	close $output;
	printf ("Output file => %s\n",$outfile);
}
