#!/usr/bin/perl -w
use strict;
use Tie::File;

my $filename="species_name.fasta";
tie (my @array,"Tie::File",$filename);
$filename=~ s/.fasta//g;

foreach my $line (@array){
    chomp $line;
	if ($line=~ /^>/){
		$line=~ s/$line/$line\_$filename/g;
	}
}
