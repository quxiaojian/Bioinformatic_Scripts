#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

my $indir="input";
my $outdir="output";
system ("rm -rf $outdir") if (-e $outdir);
system ("mkdir $outdir") if (! -e $outdir);
my $i=0;
my $infile;
my $outfile;
my %hash=("---"=>"-","TAA"=>"*","TAG"=>"*","TGA"=>"*","TCA"=>"S","TCC"=>"S","TCG"=>"S","TCT"=>"S","TTC"=>"F","TTT"=>"F","TTA"=>"L","TTG"=>"L","TAC"=>"Y","TAT"=>"Y","TGC"=>"C","TGT"=>"C","TGG"=>"W","CTA"=>"L","CTC"=>"L","CTG"=>"L","CTT"=>"L","CCA"=>"P","CCC"=>"P","CCG"=>"P","CCT"=>"P","CAC"=>"H","CAT"=>"H","CAA"=>"Q","CAG"=>"Q","CGA"=>"R","CGC"=>"R","CGG"=>"R","CGT"=>"R","ATA"=>"I","ATC"=>"I","ATT"=>"I","ATG"=>"M","ACA"=>"T","ACC"=>"T","ACG"=>"T","ACT"=>"T","AAC"=>"N","AAT"=>"N","AAA"=>"K","AAG"=>"K","AGC"=>"S","AGT"=>"S","AGA"=>"R","AGG"=>"R","GTA"=>"V","GTC"=>"V","GTG"=>"V","GTT"=>"V","GCA"=>"A","GCC"=>"A","GCG"=>"A","GCT"=>"A","GAC"=>"D","GAT"=>"D","GAA"=>"E","GAG"=>"E","GGA"=>"G","GGC"=>"G","GGG"=>"G","GGT"=>"G");
open(my $error,">>","error.txt");

while (defined ($infile=glob ($indir."/*.fasta"))) {
    printf ("(%d)\tNow processing file => %s\t",++$i,$infile);
	$outfile=$outdir."/".substr ($infile,rindex ($infile,"/")+1);

	open (my $input,"<",$infile);
	open (my $output,">",$outfile);

	while (defined (my $header=<$input>) && defined (my $seq=<$input>)){
		chomp ($header,$seq);
		print $output "$header\n";
		my $aa;
		#for (my $i=0;$i<(length($seq));$i+=3){# remain stop codon, either (length($seq)-1) or (length($seq)-2) is OK
		for (my $i=0;$i<(length ($seq))-3;$i+=3){# delete stop codon
			my $codon=substr ($seq,$i,3);
			$codon=uc $codon;
			if (exists $hash{$codon}){
				$aa.=$hash{$codon};
			}else{
				$aa.="X";
				my $j=$i+1;
				print $error "Bad codon $codon in position $j of species $header in $infile!\n";
			}
		}
		print $output "$aa\n";
	}
	close $input;
	close $output;
	printf("Output file => %s\n",$outfile);
}
