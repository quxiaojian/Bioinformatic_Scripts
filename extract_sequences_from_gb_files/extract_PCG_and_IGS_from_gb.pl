#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;
use Data::Dumper;
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

my $filename_base;
while (@filenames) {
	my $filename_gb=shift @filenames;
   	$filename_base=$filename_gb;
	$filename_base=~ s/(.*).gb/$1/g;
	my $latin_name=substr ($filename_base,rindex($filename_base,"\/")+1);

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
		my $i=0;
		if (/^LOCUS/i){
			$species_name=$latin_name;
			$length=$row_array[2];
		}elsif(/ {5}gene {12}/){
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
			}
			$element=$row_array[2];
			$mark=1;
		}elsif(/^\s+\/gene="(.*)"/ and $mark == 1){
			$element=$species_name.":".$1.":".$element;
			push @genearray,$element if ($element!~ /:trn/ and $element!~ /:rrn/);
			$element=();
			$mark=0;
		}
	}
	close $in_genbank;
	foreach (@genearray){
		my @array=split /:/,$_;
		push @output1,"$array[0]\t$array[1]\t$array[2]\n";
	}
	@row_array=();
	@genearray=();


	#put_fasta_sequence_in_array
    my $flag=0;
    my @sequence;
	my (@fas1,@fas2);
	open(my $in_genebank,"<","$filename_base\_temp2");
    while (<$in_genebank>){
        if ($_=~ /ORIGIN/){
            $flag=1;
        }
        if ($_=~ /\/\//){
            $flag=2;
        }
        if ($flag==1){
            next if ($_=~ /ORIGIN/);
            push @sequence,$_;
        }
    }
	close $in_genebank;
	foreach (@sequence){
		chomp;
		$_=~ s/\s*//g;
		$_=~ s/\d+//g;
		push @fas1,$_;
	}
    my $fas1=join "",@fas1;
    my (@fasta1,@fasta2);
    push @fasta1,$species_name,$fas1;
	@fasta2=@fasta1;

	unlink "$filename_base\_temp1";
	unlink "$filename_base\_temp2";


	#edit_bed_file
	my (%SP1,%GENE1,%STRAND1,%START1,%END1,%TYPE1,%STRAND2,%START2,%END2,%TYPE2,%STRAND3,%START3,%END3,%TYPE3,@output2);
	my $cnt1=0;
	foreach (@output1) {
		chomp;
		$cnt1++;
		($SP1{$cnt1},$GENE1{$cnt1},$STRAND1{$cnt1},$START1{$cnt1},$END1{$cnt1},$TYPE1{$cnt1},$STRAND2{$cnt1},$START2{$cnt1},$END2{$cnt1},$TYPE2{$cnt1})=(split /\s+/,$_)[0,1,2,3,4,5,6,7,8,9];
	}
	foreach (1..$cnt1) {
		if (defined $STRAND2{$_} eq "") {
			push @output2,($SP1{$_}."\t".$GENE1{$_}."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
		}elsif (defined $STRAND2{$_} ne "") {
			if (($STRAND1{$_} eq "-") and ($STRAND2{$_} eq "-") and ($START1{$_} < $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "-") and ($STRAND2{$_} eq "-") and ($START1{$_} > $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "-") and ($STRAND2{$_} eq "+") and ($START1{$_} > $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "+") and ($STRAND2{$_} eq "+") and ($START1{$_} < $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "+") and ($STRAND2{$_} eq "+") and ($START1{$_} > $START2{$_}) and ($GENE1{$_} ne "rps12")){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "+") and ($STRAND2{$_} eq "+") and ($START1{$_} > $START2{$_}) and ($GENE1{$_} eq "rps12")){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}
		}
	}
	@output1=();


	#sort_bed_file
	my $col=3;
	my (%sort,@output3);
	foreach (@output2){
		my @row=split /\t/,$_;
		$sort{$_}=$row[$col];
	}
	foreach (sort {$sort{$a} <=> $sort{$b}} keys %sort){
		push @output3,"$_\n";
	}
	@output2=();


	#output_bed_file
	open (my $out_bed,">","$filename_base\_gene.bed");
	foreach (@output3){
		my @row=split /\t/,$_;
		my $abs=abs($row[3]-$row[4]);
		if ($_!~ /rps12/) {
			print $out_bed $_;
		}
		if (($_=~ /rps12/) and ($abs < 200)) {
			$_=~ s/rps12/rps12+1/;
			print $out_bed $_;
		}
		if (($_=~ /rps12/) and ($abs > 200)) {
			$_=~ s/rps12/rps12+2/;
			print $out_bed $_;
		}
	}
	close $out_bed;


	#extract_gene
	my (%SP2,%GENE2,%STRAND4,%START4,%END4,%TYPE4,$seq1);
	my $cnt2=0;
	open(my $out_coding,">","$filename_base\_gene.fasta");
	while (@fasta1){
		my $header=shift @fasta1;
		$seq1=shift @fasta1;
	}
	foreach (@output3){
		chomp;
		$cnt2++;
		($SP2{$cnt2},$GENE2{$cnt2},$STRAND4{$cnt2},$START4{$cnt2},$END4{$cnt2},$TYPE4{$cnt2})=(split /\s+/,$_)[0,1,2,3,4,5];
		my $str=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1));
		if ($STRAND4{$cnt2} eq "-") {
			my $rev_com=reverse $str;
			$rev_com=~ tr/ACGTacgt/TGCAtgca/;
			print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$rev_com."\n";
		}elsif($STRAND4{$cnt2} eq "+"){
			print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$str."\n";
		}
	}
	close $out_coding;


	#generate_IGS_ranges
	my (%SP3,%GENE3,%STRAND5,%START5,%END5,%TYPE5,$last0,$last1,$last2,@output4);
	my $cnt3=0;
	foreach (@output3){
		chomp;
		$cnt3++;
		($SP3{$cnt3},$GENE3{$cnt3},$STRAND5{$cnt3},$START5{$cnt3},$END5{$cnt3},$TYPE5{$cnt3})=(split /\s+/,$_)[0,1,2,3,4,5];
	}
	foreach (keys %SP3){
		if ($_==1 and $START5{$_}!=1){
			unshift @output4,$SP3{$_}."\t"."start".'-'.$GENE3{$_}."\t"."?"."/".$STRAND5{$_}."\t"."1"."\t".($START5{$_}-1)."\t"."?"."/".$TYPE5{$_}."\n";
		}
	}
	foreach (1..($cnt3-1)) {
        $last0=$_-1;
		$last1=$_+1;
		$last2=$_+2;
		next if ((($END5{$_}+1) >= ($START5{$last1}-1)) and (($END5{$_}+1) < ($END5{$last1}-1)));
		next if (($_ > 1) and (($END5{$_}+1) < ($END5{$last0}-1)) and (($END5{$_}+1) < ($START5{$last2}-1)));
		if ((($END5{$_}+1) >= ($START5{$last1}-1)) and (($END5{$_}+1) >= ($END5{$last1}-1))){
    		push @output4,$SP3{$_}."\t".$GENE3{$_}.'-'.$GENE3{$last2}."\t".$STRAND5{$_}."/".$STRAND5{$last2}."\t".($END5{$_}+1)."\t".($START5{$last2}-1)."\t".$TYPE5{$_}."/".$TYPE5{$last2}."\n";
        }else{
    		push @output4,$SP3{$_}."\t".$GENE3{$_}.'-'.$GENE3{$last1}."\t".$STRAND5{$_}."/".$STRAND5{$last1}."\t".($END5{$_}+1)."\t".($START5{$last1}-1)."\t".$TYPE5{$_}."/".$TYPE5{$last1}."\n";
        }
	}
	foreach (keys %SP3){
		if ($_==$cnt3){
			push @output4,$SP3{$_}."\t".$GENE3{$_}.'-'."end"."\t".$STRAND5{$_}."/"."?"."\t".($END5{$_}+1)."\t".$length."\t".$TYPE5{$_}."/"."?"."\n";
		}
	}
	@output3=();


	#extract_IGS
	my (%SP4,%GENE4,%STRAND6,%START6,%END6,%TYPE6,$seq2);
	my $cnt4=0;
	open(my $out_noncoding,">","$filename_base\_IGS.fasta");
	while (@fasta2){
		my $header=shift @fasta2;
		$seq2=shift @fasta2;
	}
	foreach (@output4){
		chomp;
		$cnt4++;
		($SP4{$cnt4},$GENE4{$cnt4},$STRAND6{$cnt4},$START6{$cnt4},$END6{$cnt4},$TYPE6{$cnt4})=(split /\s+/,$_)[0,1,2,3,4,5];
		my $str=substr($seq2,($START6{$cnt4}-1),($END6{$cnt4}-$START6{$cnt4}+1));
		print $out_noncoding ">".$GENE4{$cnt4}."_".$SP4{$cnt4}."\n".$str."\n";
	}
	@output4=();
	close $out_noncoding;
	unlink "$filename_base\_gene.bed";
}


sub argument{
	my @options=("help|h","input|i:s","pattern|p:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'pattern'}){
		print "***ERROR: No suffix pattern is assigned!!!\n";
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

    extract_PCG_and_IGS_from_gb.pl

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

    extract PCG and IGS from gb

=head1 SYNOPSIS

    extract_PCG_and_IGS_from_gb.pl -i -p
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory.
    [-p -pattern]      required: (default: .gb) suffix pattern.

=cut
