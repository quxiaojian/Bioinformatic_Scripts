#!/usr/bin/perl -w
use strict;
$|=1;

print "Please type your filename: ";
chomp (my $filename=<STDIN>);
my $outfile="length_1.txt";
system ("unlink $outfile") if (-e $outfile);
open (my $input,"<",$filename);
open (my $output,">",$outfile);
$filename=~ s/.phy//g;

while (my $row=<$input>) {
	chomp $row;
	if ($row=~ /^\s+\d+/g) {
		$row=~ s/\s+\d+\s+(\d+)/$1/;
		print $output "$filename\t$row\n";
	}
}
close $input;
close $output;
