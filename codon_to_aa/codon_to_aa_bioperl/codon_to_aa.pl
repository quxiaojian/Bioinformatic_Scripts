#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

my $filename="atpA.fasta";
my $seqio=Bio::SeqIO->new(-file=>$filename,-format=>"fasta"); 
open (my $output,">","atpA_aa.fasta");

while (my $seqobj=$seqio->next_seq) {
	my $id=$seqobj->display_id;
	print $output ">$id\n";

	#my $seq=$seqobj->seq;
	#print $output "$seq\n";

	my $aa_seqobj=$seqobj->translate;
	my $aa_seq=$aa_seqobj->seq;
	print $output "$aa_seq\n";
}
