#!/usr/bin/perl
use strict;

my $seqfile="PCG.fasta";
my $idsfile="header.txt";
my $dir="output";
system ("mkdir $dir") if (! -e $dir);

my %ids=();

open (my $header,"<",$idsfile);
while(<$header>) {
  chomp;
  $ids{$_} += 1;
}
close $header;

open (my $fasta,"<",$seqfile);
open (my $output,">","$dir/$seqfile");
while (chomp (my $row=<$fasta>) && chomp (my $seq=<$fasta>)) {
  my $id=$1 if $row =~ /^>(\S+)/;
  print $output ">$id\n$seq\n" if (exists($ids{$id}));
}
close $fasta;
close $output;
