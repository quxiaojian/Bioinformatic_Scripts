#!/usr/bin/perl -w
use strict;
$|=1;

my $indir="input";
my $i=0;
my $infile;
my @array1;
my @array2;

while (defined($infile = glob($indir."/*.phy"))) {
	printf("(%d)\tNow processing file => %s\n",++$i,$infile);
	open (my $input,"<",$infile);

	while (my $row = <$input>) {
		chomp $row;
		if ($row=~ m/^\s+\d+/) {
			my $header=$row;
			push @array1,"$infile$header\n";
		}
	}
	close $input;
}


foreach (@array1) {
	chomp;
	my @line=split;
	push @array2,"$line[0]\t$line[2]\n";
}


print "Please type your output filename: ";
chomp (my $outfile=<STDIN>);
open (my $output,">",$outfile);

foreach (@array2){
	$_=~ s/.phy//g;
	$_=~ s/input\///g;
	$_=~ s/ //g;
	print $output $_;
}
close $output;
