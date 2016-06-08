#!usr/bin/perl -w
use strict;

my $indir="input";
my $outdir="output";
system ("mkdir $outdir") if (! -e $outdir);
my $i=0;
my $infile;
my $outfile;

while ($infile=glob($indir."/*.fasta")){
   printf("(%d)\tNow processing file => %s\t",++$i,$infile);
   $outfile=substr($infile,index($infile,"/")+1);
   open (my $input,"<",$infile);
   open (my $output,">","$outdir/$outfile");

   while (my $line=<$input>){
      chomp $line;
      if ($line=~ /^>/){
         my $newline=$line."_"."$outfile\n";
         $newline=~ s/input\///g;
         $newline=~ s/.fasta//g;
         print $output $newline;
      }else{
         print $output "$line\n";
      }
   }
   close $input;
   close $output;
   printf("Output file => %s\n","$outdir/$outfile");
}
