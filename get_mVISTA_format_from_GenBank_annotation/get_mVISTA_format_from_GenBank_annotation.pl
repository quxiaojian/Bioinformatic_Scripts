#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;
$|=1;

my $global_options=&argument();
my $indir=&default("input","input");
my $pattern=&default(".gb","pattern");

my @filenames;
find(\&target,$indir);
sub target{
    if (/$pattern/){
        push @filenames,"$File::Find::name";
    }
    return;
}

while (@filenames) {
	my $filename_gb=shift @filenames;
   	my $filename_base=$filename_gb;
	$filename_base=~ s/(.*).gb/$1/g;

	open(my $in_gb,"<",$filename_gb);
	open(my $out_gb,">","$filename_base\_temp1");
	while (<$in_gb>){
		$_=~ s/\r\n/\n/g;
		if ($_=~ /\),\n/){
			$_=~ s/\),\n/\),/g;
		}elsif($_=~ /,\n/){
			$_=~ s/,\n/,/g;
		}
		print $out_gb $_;
	}
	close $in_gb;
	close $out_gb;

	open(my $in_gbk,"<","$filename_base\_temp1");
	open(my $out_gbk,">","$filename_base\_temp2");
	while (<$in_gbk>){
		$_=~ s/,\s+/,/g;
		print $out_gbk $_;
	}
	close $in_gbk;
	close $out_gbk;


	#generate_bed_file
	my (@row_array,$species_name,$length,$element,@genearray,@output1);
	my $mark=0;
	open (my $in_genbank,"<","$filename_base\_temp2");
	while (<$in_genbank>){
		chomp;
		@row_array=split /\s+/,$_;
		if (/^LOCUS/i){
			$species_name=$row_array[1];
			$length=$row_array[2];
		}elsif(/ {5}CDS {13}/ or / {5}tRNA {12}/ or / {5}rRNA {12}/){
			if ($row_array[2]=~ /^\d+..\d+$/){
				$row_array[2]="\+\t$row_array[2]\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~/^complement\((\d+..\d+)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\((\d+..\d+),(\d+..\d+)\)$/) {
				$row_array[2]="+\t$1\t$row_array[1]\t+\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\((\d+..\d+),(\d+..\d+),(\d+..\d+)\)$/) {
				$row_array[2]="+\t$1\t$row_array[1]\t+\t$2\t$row_array[1]\t+\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\(complement\((\d+..\d+)\),complement\((\d+..\d+)\)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t-\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\(complement\((\d+..\d+)\),(\d+..\d+)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t+\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\((\d+..\d+),complement\((\d+..\d+)\)\)$/){
				$row_array[2]="+\t$1\t$row_array[1]\t-\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\(complement\((\d+..\d+)\),complement\((\d+..\d+)\),complement\((\d+..\d+)\)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t-\t$2\t$row_array[1]\t-\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^complement\(join\((\d+..\d+),(\d+..\d+)\)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t-\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^complement\(join\((\d+..\d+),(\d+..\d+),(\d+..\d+)\)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t-\t$2\t$row_array[1]\t-\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^order\((\d+..\d+),(\d+..\d+)\)$/){
				$row_array[2]="+\t$1\t$row_array[1]\t+\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^order\((\d+..\d+),(\d+..\d+),(\d+..\d+)\)$/){
				$row_array[2]="+\t$1\t$row_array[1]\t+\t$2\t$row_array[1]\t+\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^order\(complement\((\d+..\d+)\),complement\((\d+..\d+)\)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t-\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^order\(complement\((\d+..\d+)\),complement\((\d+..\d+)\),complement\((\d+..\d+)\)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t-\t$2\t$row_array[1]\t-\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^order\(complement\((\d+..\d+)\),(\d+..\d+)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t+\t$2\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^order\(complement\((\d+..\d+)\),(\d+..\d+),(\d+..\d+)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t+\t$2\t$row_array[1]\t+\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\(complement\((\d+..\d+)\),(\d+..\d+),(\d+..\d+)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]\t+\t$2\t$row_array[1]\t+\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^join\((\d+..\d+),(\d+..\d+),complement\((\d+..\d+)\)\)$/) {
				$row_array[2]="+\t$1\t$row_array[1]\t+\t$2\t$row_array[1]\t-\t$3\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^<\d+..\d+$/){
				$row_array[2]="\+\t$row_array[2]\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~ /^\d+..>\d+$/){
				$row_array[2]="\+\t$row_array[2]\t$row_array[1]";
				$row_array[2]=~ s/\..>/\t/g;
			}elsif($row_array[2]=~/^complement\(<(\d+..\d+)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]";
				$row_array[2]=~ s/\../\t/g;
			}elsif($row_array[2]=~/^complement\((\d+..>\d+)\)$/){
				$row_array[2]="-\t$1\t$row_array[1]";
				$row_array[2]=~ s/\..>/\t/g;
			}
			$element=$row_array[2];
			$mark=1;
		}elsif(/^\s+\/gene="(.*)"/ and $mark == 1){
			$element=$1.":".$element;
			push @genearray,$element;
			$element=();
			$mark=0;
		}
	}
	close $in_genbank;

	foreach (@genearray){
		my @array=split /:/,$_;
		push @output1,"$array[0]\t$array[1]\n";
	}
	unlink "$filename_base\_temp1";
	unlink "$filename_base\_temp2";

	#edit_bed_file
	my (%GENE1,%STRAND1,%START1,%END1,%TYPE1,%STRAND2,%START2,%END2,%TYPE2,%STRAND3,%START3,%END3,%TYPE3,@output2);
	my $cnt1=0;
	foreach (@output1) {
		chomp;
		$cnt1++;
		($GENE1{$cnt1},$STRAND1{$cnt1},$START1{$cnt1},$END1{$cnt1},$TYPE1{$cnt1},$STRAND2{$cnt1},$START2{$cnt1},$END2{$cnt1},$TYPE2{$cnt1},$STRAND3{$cnt1},$START3{$cnt1},$END3{$cnt1},$TYPE3{$cnt1})=(split /\s+/,$_)[0,1,2,3,4,5,6,7,8,9,10,11,12];
	}

	foreach (1..$cnt1) {
		if (defined $STRAND2{$_} eq "") {
			if ($TYPE1{$_} eq "CDS") {
				if ($STRAND1{$_} eq "-") {
					push @output2,("<"."\t".$START1{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
				}elsif ($STRAND1{$_} eq "+") {
					push @output2,(">"."\t".$START1{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
				}
			}elsif ($TYPE1{$_} eq "tRNA") {
				if ($STRAND1{$_} eq "-") {
					push @output2,("<"."\t".$START1{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}elsif ($STRAND1{$_} eq "+") {
					push @output2,(">"."\t".$START1{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}
			}elsif ($TYPE1{$_} eq "rRNA") {
				if ($STRAND1{$_} eq "-") {
					push @output2,("<"."\t".$START1{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}elsif ($STRAND1{$_} eq "+") {
					push @output2,(">"."\t".$START1{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}
			}
		}elsif ((defined $STRAND2{$_} ne "") and (defined $STRAND3{$_} eq "")) {
			if ($TYPE1{$_} eq "CDS") {
				if (($STRAND1{$_} eq "-") and ($START1{$_} < $START2{$_})){
					push @output2,("<"."\t".$START1{$_}."\t".$END2{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START2{$_})){
					push @output2,("<"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
				}elsif(($STRAND1{$_} eq "+") and ($START1{$_} < $START2{$_})){
					push @output2,(">"."\t".$START1{$_}."\t".$END2{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START2{$_})){
					push @output2,(">"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
				}
			}elsif ($TYPE1{$_} eq "tRNA") {
				if (($STRAND1{$_} eq "-") and ($START1{$_} < $START2{$_})){
					push @output2,("<"."\t".$START1{$_}."\t".$END2{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
				}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START2{$_})){
					push @output2,("<"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}elsif(($STRAND1{$_} eq "+") and ($START1{$_} < $START2{$_})){
					push @output2,(">"."\t".$START1{$_}."\t".$END2{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
				}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START2{$_})){
					push @output2,(">"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}
			}elsif ($TYPE1{$_} eq "rRNA") {
				if (($STRAND1{$_} eq "-") and ($START1{$_} < $START2{$_})){
					push @output2,("<"."\t".$START1{$_}."\t".$END2{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
				}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START2{$_})){
					push @output2,("<"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}elsif(($STRAND1{$_} eq "+") and ($START1{$_} < $START2{$_})){
					push @output2,(">"."\t".$START1{$_}."\t".$END2{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
				}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START2{$_})){
					push @output2,(">"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
					push @output2,($START2{$_}."\t".$END2{$_}."\t"."utr\n");
					push @output2,($START1{$_}."\t".$END1{$_}."\t"."utr\n");
				}
			}
		}elsif ((defined $STRAND2{$_} ne "") and (defined $STRAND3{$_} ne "")) {
			if (($STRAND1{$_} eq "-") and ($START1{$_} < $START2{$_}) and ($START2{$_} < $START3{$_})){
				push @output2,("<"."\t".$START1{$_}."\t".$END3{$_}."\t".$GENE1{$_}."\n");
				push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
				push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				push @output2,($START3{$_}."\t".$END3{$_}."\t"."exon\n");
			}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START2{$_}) and ($START2{$_} > $START3{$_})){
				push @output2,("<"."\t".$START3{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
				push @output2,($START3{$_}."\t".$END3{$_}."\t"."exon\n");
				push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
			}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START3{$_}) and ($START3{$_} > $START2{$_})){
				push @output2,("<"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
				push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				push @output2,($START3{$_}."\t".$END3{$_}."\t"."exon\n");
				push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} < $START2{$_}) and ($START2{$_} < $START3{$_})){
				push @output2,(">"."\t".$START1{$_}."\t".$END3{$_}."\t".$GENE1{$_}."\n");
				push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
				push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				push @output2,($START3{$_}."\t".$END3{$_}."\t"."exon\n");
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START2{$_}) and ($START2{$_} > $START3{$_})){
				push @output2,(">"."\t".$START3{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
				push @output2,($START3{$_}."\t".$END3{$_}."\t"."exon\n");
				push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START3{$_}) and ($START3{$_} > $START2{$_})){
				push @output2,(">"."\t".$START2{$_}."\t".$END1{$_}."\t".$GENE1{$_}."\n");
				push @output2,($START2{$_}."\t".$END2{$_}."\t"."exon\n");
				push @output2,($START3{$_}."\t".$END3{$_}."\t"."exon\n");
				push @output2,($START1{$_}."\t".$END1{$_}."\t"."exon\n");
			}
		}
	}

	#output_bed_file
	open (my $out_bed,">","$filename_base\_mVISTA.txt");
	foreach (@output2){
		print $out_bed $_;
	}
	close $out_bed;
}


##function
sub argument{
	my @options=("help|h","input|i:s","pattern|p:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
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

    get_mVISTA_format_from_GenBank_annotation.pl

=head1 COPYRIGHT

    copyright (C) 2020 Xiao-Jian Qu

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

    get mVISTA format from GenBank annotation

=head1 SYNOPSIS

    get_mVISTA_format_from_GenBank_annotation.pl -i [-p]
    example: perl get_mVISTA_format_from_GenBank_annotation.pl -i input -p .gb
    Copyright (C) 2020 Xiao-Jian Qu
    Please contact <quxiaojian@sdnu.edu.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory name.
    [-p -pattern]      optional: (default: .gb) suffix of all GenBank files.

=cut
