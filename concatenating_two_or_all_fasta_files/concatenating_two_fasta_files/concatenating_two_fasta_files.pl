#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $indir="input";
my $outdir="output";
system ("mkdir $outdir") if (! -e $outdir);
my $i=0;
my $infile1;
my $infile2;

while (defined ($infile1=glob($indir."/*_1.fasta")) and defined ($infile2=glob ($indir."/*_PUIS.fasta"))){
	my $filename1=substr ($infile1,index ($infile1,"/")+1);
	my $left1=substr ($filename1,0,index ($filename1,"_"));
	#my $right1=substr ($filename1,index ($filename1,"_")+1,-6);
	my $filename2=substr ($infile2,index ($infile2,"/")+1);
	my $left2=substr ($filename2,0,index ($filename2,"_"));
	#my $right2=substr ($filename2,index ($filename2,"_")+1,-6);

	printf("(%d)\tNow processing file => %s\n",++$i,"$infile1 and $filename2");
	if ($left1 eq $left2) {
		open (my $input1,"<",$infile1);
		open (my $input2,"<",$infile2);
		open (my $output,">","$outdir/$left1\_slow.fasta");
    	my %hash;

		while (defined (my $header1=<$input1>) && defined (my $seq1=<$input1>)) {
			chomp ($header1,$seq1);
			my $id1=$1 if $header1=~ /^(>\S+)/;
			$hash{$id1}=$seq1;
		}
		while (defined (my $header2=<$input2>) && defined (my $seq2=<$input2>)) {
			chomp ($header2,$seq2);
			my $id2=$1 if $header2=~ /^(>\S+)/;
			$hash{$id2}.=$seq2;
		}
		foreach my $key (sort {$a cmp $b} keys %hash){
			print $output "$key\n$hash{$key}\n";
		}
	}
}
