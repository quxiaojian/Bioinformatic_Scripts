#!/usr/bin/perl -w
use strict;

my $filename="species_name.fasta";
open (my $input,"<",$filename);
open (my $output,">","new_species_name.fasta");
$filename=~ s/.fasta//g;

while (my $line=<$input>){
    chomp $line;
	if ($line=~ /^>/){
		my $newline=$line."_".$filename;
		print $output $newline."\n";
	}else{
		print $output $line."\n";
	}
}
close $input;
close $output;
