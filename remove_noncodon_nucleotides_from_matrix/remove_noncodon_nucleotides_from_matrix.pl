#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;
use File::Copy;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","indir");
my $match=&default(".fasta","match");
my $reference=&default("reference","reference");
my $outdir=&default("output","outdir");
my $log=&default("warning","log");

my $temp_dir1="temp1";
my $temp_dir2="temp2";
my $warning="$log.log";
my $osname=$^O;
if ($osname eq "MSWin32") {
	#system("del/f/s/q $outdir") if (-e $outdir);
	#system("del/f/s/q $temp_dir1") if (-e $temp_dir1);
	system("rd/s/q $outdir") if (-e $outdir);
	system("rd/s/q $temp_dir1") if (-e $temp_dir1);
	system("rd/s/q $temp_dir2") if (-e $temp_dir2);
	system("del $warning") if (-e $warning);
}elsif ($osname eq "cygwin") {
	system("rm -rf $outdir") if (-e $outdir);
	system("rm -rf $temp_dir1") if (-e $temp_dir1);
	system("rm -rf $temp_dir2") if (-e $temp_dir2);
	system("rm -rf $warning") if (-e $warning);
}elsif ($osname eq "linux") {
	system("rm -rf $outdir") if (-e $outdir);
	system("rm -rf $temp_dir1") if (-e $temp_dir1);
	system("rm -rf $temp_dir2") if (-e $temp_dir2);
	system("rm -rf $warning") if (-e $warning);
}elsif ($osname eq "darwin") {
	system("rm -rf $outdir") if (-e $outdir);
	system("rm -rf $temp_dir1") if (-e $temp_dir1);
	system("rm -rf $temp_dir2") if (-e $temp_dir2);
	system("rm -rf $warning") if (-e $warning);
}
mkdir ($outdir) if (!-e $outdir);
mkdir ($temp_dir1) if (!-e $temp_dir1);
mkdir ($temp_dir2) if (!-e $temp_dir2);

my %hash_codon=("---"=>"-","TAA"=>"*","TAG"=>"*","TGA"=>"*","TCA"=>"S","TCC"=>"S","TCG"=>"S","TCT"=>"S","TTC"=>"F","TTT"=>"F","TTA"=>"L","TTG"=>"L","TAC"=>"Y","TAT"=>"Y","TGC"=>"C","TGT"=>"C","TGG"=>"W","CTA"=>"L","CTC"=>"L","CTG"=>"L","CTT"=>"L","CCA"=>"P","CCC"=>"P","CCG"=>"P","CCT"=>"P","CAC"=>"H","CAT"=>"H","CAA"=>"Q","CAG"=>"Q","CGA"=>"R","CGC"=>"R","CGG"=>"R","CGT"=>"R","ATA"=>"I","ATC"=>"I","ATT"=>"I","ATG"=>"M","ACA"=>"T","ACC"=>"T","ACG"=>"T","ACT"=>"T","AAC"=>"N","AAT"=>"N","AAA"=>"K","AAG"=>"K","AGC"=>"S","AGT"=>"S","AGA"=>"R","AGG"=>"R","GTA"=>"V","GTC"=>"V","GTG"=>"V","GTT"=>"V","GCA"=>"A","GCC"=>"A","GCG"=>"A","GCT"=>"A","GAC"=>"D","GAT"=>"D","GAA"=>"E","GAG"=>"E","GGA"=>"G","GGC"=>"G","GGG"=>"G","GGT"=>"G");

my @filenames;
find(\&target,$indir);
sub target{
	if (/$match/){
		push @filenames,"$File::Find::name";
	}
	return;
}

while (@filenames) {
	my $name1=shift @filenames;#input/atpA.fasta
	my $name2=substr($name1,(rindex($name1,"\/")+1));#atpA.fasta
	my $name3=$name2;
	$name3=~ s/$match//g;#atpA
	#copy ("$name1","$temp_dir1/$name2");
	mkdir ("$temp_dir1/$name3");
	open(my $in_fasta,"<",$name1);#input/atpA.fasta
	open(my $out_fasta,">","$temp_dir1/$name2");#temp/atpA.fasta
	my $row=<$in_fasta>;
	print $out_fasta $row;
	while ($row=<$in_fasta>){
		chomp $row;
		if ($row=~ /^>/) { 
			print $out_fasta "\n".$row."\n";
		}else{
			print $out_fasta $row; 
		}
	}
	print $out_fasta "\n";
	close $in_fasta;
	close $out_fasta;

	open(my $input,"<","$temp_dir1/$name2");#temp/atpA.fasta
	my %hash;
	my ($header,$sequence);
	while (defined ($header=<$input>) and defined ($sequence=<$input>)){
		chomp($header,$sequence);
		my $species_name=$header;
		$sequence=~ s/-//g;
		my $length;
		if ($osname eq "MSWin32") {
			$length=length $sequence;
		}elsif ($osname eq "cygwin") {
			$length=(length $sequence)-1;
		}elsif ($osname eq "linux") {
			$length=(length $sequence)-1;
		}elsif ($osname eq "darwin") {
			$length=(length $sequence)-1;
		}
		$species_name=~ s/\>//g;
		$species_name=~ s/\s//g;
		if ($species_name ne $reference) {
			$hash{$species_name}=$length;#$hash{xxx}=1000
		}
		$species_name=$species_name.$match;#xxx.fasta
		open(my $output,">","$temp_dir1/$name3/$species_name");#temp/atpA/xxx.fasta
		if ($species_name eq ($reference.$match)) {#equal to reference.fasta
			my $aa=nt_to_aa2($sequence,$length,%hash_codon);
			print $output "$header\n$aa\n";
		}elsif ($species_name ne ($reference.$match)) {#not equal to reference.fasta
			print $output "$header\n$sequence\n";
		}
		close $output;
	}
	close $input;
	#print Dumper \%hash;

	my (%hash_left,%hash_right);
	foreach my $key (keys %hash) {
		my $species_fasta=$key.$match;#xxx.fasta
		if ($osname eq "MSWin32") {
			system ("makeblastdb.exe -in $temp_dir1/$name3/$species_fasta -hash_index -dbtype nucl");
			system ("tblastn.exe -task tblastn -query $temp_dir1/$name3/$reference$match -db $temp_dir1/$name3/$species_fasta -outfmt 6 -max_hsps 1 -max_target_seqs 1 -out $temp_dir1/$name3/blast_reference_$species_fasta");
		}elsif ($osname eq "cygwin") {
			system ("makeblastdb -in $temp_dir1/$name3/$species_fasta -hash_index -dbtype nucl");
			system ("tblastn -task tblastn -query $temp_dir1/$name3/$reference$match -db $temp_dir1/$name3/$species_fasta -outfmt 6 -max_hsps 1 -max_target_seqs 1 -out $temp_dir1/$name3/blast_reference_$species_fasta");
		}elsif ($osname eq "linux") {
			system ("makeblastdb -in $temp_dir1/$name3/$species_fasta -hash_index -dbtype nucl");
			system ("tblastn -task tblastn -query $temp_dir1/$name3/$reference$match -db $temp_dir1/$name3/$species_fasta -outfmt 6 -max_hsps 1 -max_target_seqs 1 -out $temp_dir1/$name3/blast_reference_$species_fasta");
		}elsif ($osname eq "darwin") {
			system ("makeblastdb -in $temp_dir1/$name3/$species_fasta -hash_index -dbtype nucl");
			system ("tblastn -task tblastn -query $temp_dir1/$name3/$reference$match -db $temp_dir1/$name3/$species_fasta -outfmt 6 -max_hsps 1 -max_target_seqs 1 -out $temp_dir1/$name3/blast_reference_$species_fasta");
		}

		open(my $in,"<","$temp_dir1/$name3/blast_reference_$species_fasta");#temp/atpA/blast_reference_xxx.fasta
		while (<$in>) {
			chomp;
			my ($item1,$species,$item3,$item4,$item5,$item6,$qstart,$qend,$sstart,$send,$item11,$item12)=split /\t/,$_;
			my $remainder1=($sstart-1)%3;
			my $remainder2=($hash{$species}-$send)%3;
			if ($remainder1 == 1) {
				$hash_left{$key}=1;
			}elsif ($remainder1 == 2) {
				$hash_left{$key}=2;
			}elsif ($remainder1 == 0) {
				$hash_left{$key}=0;
			}

			if ($remainder2 == 1) {
				$hash_right{$key}=1;
			}elsif ($remainder2 == 2) {
				$hash_right{$key}=2;
			}elsif ($remainder2 == 0) {
				$hash_right{$key}=0;
			}
		}
		close $in;
	}
	#print Dumper %hash_left;
	#print Dumper %hash_right;

	open(my $inputs,"<","$temp_dir1/$name2");#temp/atpA.fasta
	open(my $outputs,">","$temp_dir2/$name2");#output/atpA.fasta
	my $name4=$name2;
	$name4=~ s/$name3/$name3\_aa/g;#atpA_aa.fasta
	open(my $output_aa,">","$outdir/$name4");#output/atpA_aa.fasta
	open (my $logfile,">>",$warning);#warning.log
	my ($head,$seq);
	while (defined ($head=<$inputs>) and defined ($seq=<$inputs>)){#non-interleaved fasta sequence
		chomp($head,$seq);
		my $spec_name=$head;
		$spec_name=~ s/\>//g;
		$spec_name=~ s/\s//g;
		my @seq=split //,$seq;#reference: right TCT TA- --- A-- ---; non-reference: left --- --G TCT GCG

		my ($lengs,$seqs,$lens,$aass,@aass);
		if ($osname eq "MSWin32") {
			$lengs=length $seq;
		}elsif ($osname eq "cygwin") {
			$lengs=(length $seq)-1;
		}elsif ($osname eq "linux") {
			$lengs=(length $seq)-1;
		}elsif ($osname eq "darwin") {
			$lengs=(length $seq)-1;
		}

		if ($spec_name eq $reference) {#reference species
			my @nt;
			foreach (0..$#seq){
				if (($seq[$_]=~ /\w/) and ($seq[$_])!~ /-/){
					push @nt,$_;
				}
			}
			if ((($seq[$nt[-3]] eq "T") and ($seq[$nt[-2]] eq "A") and (($seq[$nt[-1]] eq "A") or ($seq[$nt[-1]] eq "G"))) or (($seq[$nt[-3]] eq "T") and ($seq[$nt[-2]] eq "G") and ($seq[$nt[-1]] eq "A"))) {#(((T)A(A|G))|((T)GA))
				$seq[$nt[-3]]="-";
				$seq[$nt[-2]]="-";
				$seq[$nt[-1]]="-";
			}
			$seqs=join("",@seq);#
			print $outputs "$head\n$seqs\n";


			$seqs=~ s/-//g;
			if ($osname eq "MSWin32") {
				$lens=length $seqs;
			}elsif ($osname eq "cygwin") {
				$lens=(length $seqs)-1;
			}elsif ($osname eq "linux") {
				$lens=(length $seqs)-1;
			}elsif ($osname eq "darwin") {
				$lens=(length $seqs)-1;
			}
			$aass=nt_to_aa1($seqs,$lens,%hash_codon);
			print $output_aa "$head\n$aass\n";
			@aass=split //,$aass;
			foreach (1..$#aass) {
				if ($aass[$_] eq "*") {
					my $j=($_+1)*3-2;
					print $logfile "Bad codon in nucleotide position $j of species $spec_name from gene $name3!\n";
				}
			}
		}elsif ($spec_name ne $reference) {#non-reference species
			if ((exists $hash_left{$spec_name}) and ($hash_left{$spec_name} == 1)) {
				my @nt;
				foreach (0..$#seq){
					if (($seq[$_]=~ /\w/) and ($seq[$_])!~ /-/){
						push @nt,$_;
					}
				}
				$seq[$nt[0]]="-";
			}elsif ((exists $hash_left{$spec_name}) and ($hash_left{$spec_name} == 2)) {
				my @nt;
				foreach (0..$#seq){
					if (($seq[$_]=~ /\w/) and ($seq[$_])!~ /-/){
						push @nt,$_;
					}
				}
				$seq[$nt[0]]="-";
				$seq[$nt[1]]="-";
			}

			if ((exists $hash_right{$spec_name}) and ($hash_right{$spec_name} == 1)) {
				my @nt;
				foreach (0..$#seq){
					if (($seq[$_]=~ /\w/) and ($seq[$_])!~ /-/){
						push @nt,$_;
					}
				}
				$seq[$nt[-1]]="-";
			}elsif ((exists $hash_right{$spec_name}) and ($hash_right{$spec_name} == 2)) {
				my @nt;
				foreach (0..$#seq){
					if (($seq[$_]=~ /\w/) and ($seq[$_])!~ /-/){
						push @nt,$_;
					}
				}
				$seq[$nt[-1]]="-";
				$seq[$nt[-2]]="-";
			}
			my @nt;
			foreach (0..$#seq){
				if (($seq[$_]=~ /\w/) and ($seq[$_])!~ /-/){
					push @nt,$_;
				}
			}
			if ((($seq[$nt[-3]] eq "T") and ($seq[$nt[-2]] eq "A") and (($seq[$nt[-1]] eq "A") or ($seq[$nt[-1]] eq "G"))) or (($seq[$nt[-3]] eq "T") and ($seq[$nt[-2]] eq "G") and ($seq[$nt[-1]] eq "A"))) {#(((T)A(A|G))|((T)GA))
				$seq[$nt[-3]]="-";
				$seq[$nt[-2]]="-";
				$seq[$nt[-1]]="-";
			}
			$seqs=join("",@seq);
			print $outputs "$head\n$seqs\n";


			$seqs=~ s/-//g;#TCT GCG
			if ($osname eq "MSWin32") {
				$lens=length $seqs;
			}elsif ($osname eq "cygwin") {
				$lens=(length $seqs)-1;
			}elsif ($osname eq "linux") {
				$lens=(length $seqs)-1;
			}elsif ($osname eq "darwin") {
				$lens=(length $seqs)-1;
			}
			$aass=nt_to_aa1($seqs,$lens,%hash_codon);
			print $output_aa "$head\n$aass\n";
			@aass=split //,$aass;
			foreach (1..$#aass) {
				if ($aass[$_] eq "*") {
					my $j=($_+1)*3-2;
					print $logfile "Bad codon in nucleotide position $j of species $spec_name from gene $name3!\n";
				}
			}
		}
	}
	close $inputs;
	close $outputs;
	close $output_aa;
	close $logfile;


	#remove gap from alignment site
	{
		open(my $input_gap,"<","$temp_dir2/$name2");#temp/atpA.fasta
		open(my $output_gap,">","$outdir/$name2");#output/atpA.fasta

		my ($header,$sequence,$length,@id,@array);
		while (defined ($header=<$input_gap>) && defined ($sequence=<$input_gap>)) {
			chomp ($header,$sequence);
			$length=length $sequence;
			push @id,$header;

			for (0..$length-1){
				push @{$array[$_]},substr($sequence,$_,1);
			}
		}
		#print Dumper \@array;#36 array_ref in array_ref

		my @polymorphic_array;#polymorphic_array sites,first array_ref is fisrt column
		for my $column (0..$#array){#1 of 36 columns
			for my $nucleotide ($array[$column]){#1 of 4 nt in each column
				my %seen;
				if ((grep {$_ ne $nucleotide->[0]} @$nucleotide) or (($nucleotide->[0] ne "-") and (grep {$_ eq $nucleotide->[0]} @$nucleotide))) {
					push @polymorphic_array,[@$nucleotide];
					delete $array[$column];#undefined
				}
			}
		}
		@array=grep {defined $_} @array;#non-polymorphic_array sites,remove undefined elements
		#print Dumper \@polymorphic_array;

		my @transposed_polymorphic_array=map {my $x=$_;[map {$polymorphic_array[$_][$x]} (0..$#polymorphic_array)]} (0..$#{$polymorphic_array[0]});#polymorphic_array sites,first array_ref is first row
		for (0..(@id-1)){
			print $output_gap $id[$_],"\n",@{$transposed_polymorphic_array[$_]},"\n";
		}

		#my @transposed_array=map {my $x=$_;[map {$array[$_][$x]} (0..$#array)]} (0..$#{$array[0]});#non-gap sites,first array_ref is first row
		#for (0..(@id-1)){
			#print $output_gap $id[$_],"\n",@{$transposed_array[$_]},"\n";
		#}
		close $input_gap;
		close $output_gap;
	}
}

if ($osname eq "MSWin32") {
	#system("del/f/s/q $temp_dir1");
	system("rd/s/q $temp_dir1");
	system("rd/s/q $temp_dir2");
}elsif ($osname eq "cygwin") {
	system("rm -rf $temp_dir1");
	system("rm -rf $temp_dir2");
}elsif ($osname eq "linux") {
	system("rm -rf $temp_dir1");
	system("rm -rf $temp_dir2");
}elsif ($osname eq "darwin") {
	system("rm -rf $temp_dir1");
	system("rm -rf $temp_dir2");
}




###function###
sub argument{
	my @options=("help|h","indir|i:s","match|m:s","reference|r:s","outdir|o:s","log|l:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'help'});
	if(!exists $options{'indir'}){
		print "***ERROR: No input directory name are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'match'}){
		print "***ERROR: No match pattern are assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'reference'}){
		print "***ERROR: No reference species name are assigned!!!\n";
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

sub nt_to_aa1{
	my ($seq,$len,%hash_codon)=@_;
	my $aa;
	for (my $i=0;$i<$len;$i+=3){
		my $codon=substr ($seq,$i,3);
		$codon=uc $codon;
		if (exists $hash_codon{$codon}){
			$aa.=$hash_codon{$codon};
		}else{
			$aa.="?";
		}
	}
	return $aa;
}

sub nt_to_aa2{
	my ($seq,$len,%hash_codon)=@_;
	my $aa;
	for (my $i=0;$i<($len-3);$i+=3){
		my $codon=substr ($seq,$i,3);
		$codon=uc $codon;
		if (exists $hash_codon{$codon}){
			$aa.=$hash_codon{$codon};
		}else{
			$aa.="?";
		}
	}
	return $aa;
}

__DATA__

=head1 NAME

    remove_noncodon_nucleotides_from_matrix.pl

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

    remove noncodon nucleotides from matrix

=head1 SYNOPSIS

    remove_noncodon_nucleotides_from_matrix.pl [-i -m -r] -o -l
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact me <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]           help information.
    [-i -indir]          input directory name(default: input).
    [-m -match]          match pattern of alignment file name (default: .fasta).
    [-r -reference]      reference species name (default: reference).
    [-o -outdir]         output directory name (default: output).
    [-l -log]            log file name containing warning information (default: warning).

=cut
