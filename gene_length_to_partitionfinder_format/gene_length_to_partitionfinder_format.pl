#!/usr/bin/perl -w
use strict;

my $sum=0;
open(my $input,"<","length.txt");
open(my $output,">","newlength.txt");

while(my $line=<$input>){
	my ($gene,$length)=split(/\s+/,$line);
	$sum=$sum+$length;
	my $sumlength=$sum+1-$length;
	print $output "$gene = $sumlength-$sum;\n";
}
