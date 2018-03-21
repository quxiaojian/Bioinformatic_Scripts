#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","input");
my $outdir=&default("output","output");
my $log=&default("log.txt","log");

my $osname=$^O;
if ($osname eq "MSWin32") {
	system("del/f/s/q $outdir") if (-e $outdir);
}elsif ($osname eq "cygwin") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "linux") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "darwin") {
	system("rm -rf $outdir") if (-e $outdir);
}
mkdir ($outdir) if (!-e $outdir);

my %hash=("---"=>"-","TAA"=>"*","TAG"=>"*","TGA"=>"*","TCA"=>"S","TCC"=>"S","TCG"=>"S","TCT"=>"S","TTC"=>"F","TTT"=>"F","TTA"=>"L","TTG"=>"L","TAC"=>"Y","TAT"=>"Y","TGC"=>"C","TGT"=>"C","TGG"=>"W","CTA"=>"L","CTC"=>"L","CTG"=>"L","CTT"=>"L","CCA"=>"P","CCC"=>"P","CCG"=>"P","CCT"=>"P","CAC"=>"H","CAT"=>"H","CAA"=>"Q","CAG"=>"Q","CGA"=>"R","CGC"=>"R","CGG"=>"R","CGT"=>"R","ATA"=>"I","ATC"=>"I","ATT"=>"I","ATG"=>"M","ACA"=>"T","ACC"=>"T","ACG"=>"T","ACT"=>"T","AAC"=>"N","AAT"=>"N","AAA"=>"K","AAG"=>"K","AGC"=>"S","AGT"=>"S","AGA"=>"R","AGG"=>"R","GTA"=>"V","GTC"=>"V","GTG"=>"V","GTT"=>"V","GCA"=>"A","GCC"=>"A","GCG"=>"A","GCT"=>"A","GAC"=>"D","GAT"=>"D","GAA"=>"E","GAG"=>"E","GGA"=>"G","GGC"=>"G","GGG"=>"G","GGT"=>"G");
open(my $error,">",$log);

my $i=0;
my ($infile,$outfile);
while (defined ($infile=glob ($indir."/*.fasta"))) {
	printf ("(%d)\tNow processing file => %s\t",++$i,$infile);
	$outfile=$outdir."/".substr ($infile,rindex ($infile,"/")+1);
	open (my $input,"<",$infile);
	open (my $output,">",$outfile);
	my ($header,$seq,$length);
	while (defined ($header=<$input>) and defined ($seq=<$input>)){
		#chomp ($header,$seq);
		$header=~ s/\r|\n//g;
		$seq=~ s/\r|\n//g;
		$length=length $seq;
		print $output "$header\n";
		my $aa;
		for (my $i=0;$i<$length;$i+=3){# remain stop codon, either (length($seq)-1) or (length($seq)-2) is OK
		#for (my $i=0;$i<($length-3);$i+=3){# delete stop codon
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
close $error;


##function
sub argument{
	my @options=("help|h","input|i:s","output|o:s","log|l:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'log'}){
		print "***ERROR: No log filename is assigned!!!\n";
		exec ("pod2usage $0");
	}
	return \%options;
}

sub default{
	my ($default_value,$option)=@_;
	if(exists $global_options->{$option}){
		return $global_options->{$option};
	}
	return $default_value;
}


__DATA__

=head1 NAME

    codon_to_aa.pl

=head1 COPYRIGHT

    copyright (C) 2018 Xiao-Jian Qu

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION

    codon to aa

=head1 SYNOPSIS

    codon_to_aa.pl -i -o -l
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory name.
    [-o -output]       required: (default: output) output directory name.
    [-l -log]          required: (default: log.txt) log filename.

=cut
