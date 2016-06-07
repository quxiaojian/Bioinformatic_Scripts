#!usr/bin/perl

my $indir="input";
my $outdir="output";
system ("mkdir $outdir") if (! -e $outdir);
my $i=1;

while (my $infile = glob("$indir/*.fasta")) {
  printf ("(%d)\tNow processing file => %s\t",$i++,$infile);
  $outfile = $outdir."/".substr($infile,index($infile,"/")+1);
  open (my $fasta,"<",$infile);
  open (my $output,">","$outfile");

  my $idsfile="header.txt";
  my %ids=();
  open (my $header,"<",$idsfile);
  while(<$header>) {
    chomp;
    $ids{$_} += 1;
  }
  close $header;

  while (chomp (my $row=<$fasta>) && chomp (my $seq=<$fasta>)) {
    my $id=$1 if $row =~ /^>(\S+)/;
    print $output ">$id\n$seq\n" if (exists($ids{$id}));
  }
  close $fasta;
  close $output;
  printf("Output file => %s\n",$outfile);
}
