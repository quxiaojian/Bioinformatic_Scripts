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
#my %sequences;

while (defined($infile=glob($indir."/*.fasta"))) {
    printf("(%d)\tNow processing file => %s\t",++$i,$infile);
	$outfile=$outdir."/".substr($infile,rindex($infile,"/")+1);

	open (my $input,"<",$infile);
	open (my $output,">",$outfile);
	my $seqio=Bio::SeqIO->new(-file=>$infile,-format=>"fasta");

	while(my $seqobj=$seqio->next_seq){
        my $id=$seqobj->display_id;
		print $output ">$id\n";
		#my $seq=$seqobj->seq;
		#print $output "$seq\n";
		#$sequences{$id}=$seq;

		my $aa_seqobj=$seqobj->translate;
		my $aa_seq=$aa_seqobj->seq;
		print $output "$aa_seq\n";
	}

	close $input;
	close $output;
	printf("Output file => %s\n",$outfile);
}
