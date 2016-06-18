#!/usr/bin/perl -w
use strict;

my $indir="input";
my $i=0;
my $infile;
my $outfile="length_all.txt";
system ("unlink $outfile") if (-e $outfile);

while (defined($infile=glob($indir."/*.phy"))) {
    printf("(%d)\tNow processing file => %s\t",++$i,$infile);
	open (my $input,"<",$infile);
	open (my $output,">>",$outfile);
	$infile=~ s/$indir\/(\S+).phy/$1/g;

	while (my $row=<$input>){
        chomp $row;
		if ($row=~ m/^\s+\d+/g){
		    $row=~ s/\s+\d+\s+(\d+)/$1/g;
		    print $output "$infile\t$row\n";
		}
    }

    close $input;
    close $output;
    printf("Output file => %s\n",$outfile);
}
