#!/usr/bin/perl -w
use strict;

my $filename="FC274.fasta";
open (my $input,"<",$filename);
open (my $output,">","$filename.copy");
my %hash;
print "Duplicate rows are listed!\n";
while (my $row=<$input>){
	$hash{$row}++;
	if ($hash{$row}==1){
		print $output $row;			
	}
	if ($hash{$row}!=1) {
		print $row;
	}
}
