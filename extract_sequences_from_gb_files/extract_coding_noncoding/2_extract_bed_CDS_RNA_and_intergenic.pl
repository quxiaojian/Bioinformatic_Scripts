#!/usr/bin/perl -w
use strict;
use File::Find;
use Data::Dumper;
$|=1;

print "Please type your input directory:";
my $dirname=<STDIN>;
chomp $dirname;

my $pattern=".gb";
my @filenames;
find(\&target,$dirname);
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
			push @genearray,$element;
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
		($SP1{$cnt1},$GENE1{$cnt1},$STRAND1{$cnt1},$START1{$cnt1},$END1{$cnt1},$TYPE1{$cnt1},$STRAND2{$cnt1},$START2{$cnt1},$END2{$cnt1},$TYPE2{$cnt1},$STRAND3{$cnt1},$START3{$cnt1},$END3{$cnt1},$TYPE3{$cnt1})=(split /\s+/,$_)[0,1,2,3,4,5,6,7,8,9,10,11,12,13];
	}

	foreach (1..$cnt1) {
		if (defined $STRAND2{$_} eq "") {
			push @output2,($SP1{$_}."\t".$GENE1{$_}."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
		}elsif ((defined $STRAND2{$_} ne "") and (defined $STRAND3{$_} eq "")) {
			if (($STRAND1{$_} eq "-") and ($START1{$_} < $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} < $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
			}
		}elsif ((defined $STRAND2{$_} ne "") and (defined $STRAND3{$_} ne "")) {
			if (($STRAND1{$_} eq "-") and ($START1{$_} < $START2{$_}) and ($START2{$_} < $START3{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-3"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND3{$_}."\t".$START3{$_}."\t".$END3{$_}."\t".$TYPE3{$_});
			}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START2{$_}) and ($START2{$_} > $START3{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-3"."\t".$STRAND3{$_}."\t".$START3{$_}."\t".$END3{$_}."\t".$TYPE3{$_});
			}elsif(($STRAND1{$_} eq "-") and ($START1{$_} > $START3{$_}) and ($START3{$_} > $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-3"."\t".$STRAND3{$_}."\t".$START3{$_}."\t".$END3{$_}."\t".$TYPE3{$_});
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} < $START2{$_}) and ($START2{$_} < $START3{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-3"."\t".$STRAND3{$_}."\t".$START3{$_}."\t".$END3{$_}."\t".$TYPE3{$_});
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START2{$_}) and ($START2{$_} > $START3{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-3"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND3{$_}."\t".$START3{$_}."\t".$END3{$_}."\t".$TYPE3{$_});
			}elsif(($STRAND1{$_} eq "+") and ($START1{$_} > $START3{$_}) and ($START3{$_} > $START2{$_})){
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-1"."\t".$STRAND1{$_}."\t".$START1{$_}."\t".$END1{$_}."\t".$TYPE1{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-2"."\t".$STRAND2{$_}."\t".$START2{$_}."\t".$END2{$_}."\t".$TYPE2{$_});
				push @output2,($SP1{$_}."\t".$GENE1{$_}."-3"."\t".$STRAND3{$_}."\t".$START3{$_}."\t".$END3{$_}."\t".$TYPE3{$_});
			}
		}
	}


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
	open (my $out_bed,">","$filename_base\_bed_CDS_RNA_intergenic.txt");
	foreach (@output3){
		print $out_bed $_;
	}
	close $out_bed;


	#extract_gene
	my (%SP2,%GENE2,%STRAND4,%START4,%END4,%TYPE4,%STRAND5,%START5,%END5,%TYPE5,%STRAND6,%START6,%END6,%TYPE6,$seq1);
	my $cnt2=0;
	open(my $out_coding,">","$filename_base\_CDS_RNA.fasta");
	while (@fasta1){
		my $header=shift @fasta1;
		$seq1=shift @fasta1;
	}
	foreach (@output1){
		chomp;
		$cnt2++;
		($SP2{$cnt2},$GENE2{$cnt2},$STRAND4{$cnt2},$START4{$cnt2},$END4{$cnt2},$TYPE4{$cnt2},$STRAND5{$cnt2},$START5{$cnt2},$END5{$cnt2},$TYPE5{$cnt2},$STRAND6{$cnt2},$START6{$cnt2},$END6{$cnt2},$TYPE6{$cnt2})=(split /\s+/,$_)[0,1,2,3,4,5,6,7,8,9,10,11,12,13];
		if (defined $STRAND5{$cnt2} eq "") {
        	my $str1=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1));
            if ($STRAND4{$cnt2} eq "-") {
                my $rev_com1=reverse $str1;
                $rev_com1=~ tr/ACGTacgt/TGCAtgca/;
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$rev_com1."\n";
            }elsif($STRAND4{$cnt2} eq "+"){
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$str1."\n";
            }
        }elsif((defined $STRAND5{$cnt2} ne "") and (defined $STRAND6{$cnt2} eq "")) {
            if (($STRAND4{$cnt2} eq "-") and ($START4{$cnt2} < $START5{$cnt2})) {
                my $str2=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1)).substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1));
                my $rev_com2=reverse $str2;
                $rev_com2=~ tr/ACGTacgt/TGCAtgca/;
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$rev_com2."\n";
            }elsif(($STRAND4{$cnt2} eq "-") and ($START4{$cnt2} > $START5{$cnt2})) {
                my $str3=substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1));
                my $rev_com3=reverse $str3;
                $rev_com3=~ tr/ACGTacgt/TGCAtgca/;
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$rev_com3."\n";
            }elsif(($STRAND4{$cnt2} eq "+") and ($START4{$cnt2} < $START5{$cnt2})){
                my $str4=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1)).substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1));
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$str4."\n";
            }elsif(($STRAND4{$cnt2} eq "+") and ($START4{$cnt2} > $START5{$cnt2})){
                my $str5=substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1));
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$str5."\n";
            }
        }elsif ((defined $STRAND5{$cnt2} ne "") and (defined $STRAND6{$cnt2} ne "")) {
            if (($STRAND4{$cnt2} eq "-") and ($START4{$cnt2} < $START5{$cnt2}) and ($START5{$cnt2} < $START6{$cnt2})) {
                my $str6=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1)).substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START6{$cnt2}-1),($END6{$cnt2}-$START6{$cnt2}+1));
                my $rev_com4=reverse $str6;
                $rev_com4=~ tr/ACGTacgt/TGCAtgca/;
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$rev_com4."\n";
            }elsif(($STRAND4{$cnt2} eq "-") and ($START4{$cnt2} > $START5{$cnt2}) and ($START5{$cnt2} > $START6{$cnt2})) {
                my $str7=substr($seq1,($START6{$cnt2}-1),($END6{$cnt2}-$START6{$cnt2}+1)).substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1));
                my $rev_com5=reverse $str7;
                $rev_com5=~ tr/ACGTacgt/TGCAtgca/;
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$rev_com5."\n";
            }elsif(($STRAND4{$cnt2} eq "-") and ($START4{$cnt2} > $START6{$cnt2}) and ($START6{$cnt2} > $START5{$cnt2})) {
                my $str8=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1));
                my $str9=substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START6{$cnt2}-1),($END6{$cnt2}-$START6{$cnt2}+1));
                my $rev_com6=reverse $str8;
                $rev_com6=~ tr/ACGTacgt/TGCAtgca/;
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$rev_com6.$str9."\n";
            }elsif(($STRAND4{$cnt2} eq "+") and ($START4{$cnt2} < $START5{$cnt2}) and ($START5{$cnt2} < $START6{$cnt2})){
                my $str10=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1)).substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START6{$cnt2}-1),($END6{$cnt2}-$START6{$cnt2}+1));
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$str10."\n";
            }elsif(($STRAND4{$cnt2} eq "+") and ($START4{$cnt2} > $START5{$cnt2}) and ($START5{$cnt2} > $START6{$cnt2})){
                my $str11=substr($seq1,($START6{$cnt2}-1),($END6{$cnt2}-$START6{$cnt2}+1)).substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1));
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$str11."\n";
            }elsif(($STRAND4{$cnt2} eq "+") and ($START4{$cnt2} > $START6{$cnt2}) and ($START6{$cnt2} > $START5{$cnt2})) {
                my $str12=substr($seq1,($START4{$cnt2}-1),($END4{$cnt2}-$START4{$cnt2}+1)).substr($seq1,($START5{$cnt2}-1),($END5{$cnt2}-$START5{$cnt2}+1)).substr($seq1,($START6{$cnt2}-1),($END6{$cnt2}-$START6{$cnt2}+1));
                print $out_coding ">".$GENE2{$cnt2}."_".$SP2{$cnt2}."\n".$str12."\n";
            }
        }
	}
	close $out_coding;
    @output1=();


	#generate_IGS_ranges
	my (%SP3,%GENE3,%STRAND7,%START7,%END7,%TYPE7,$last0,$last1,$last2,@output4);
	my $cnt3=0;
	foreach (@output3){
		chomp;
		$cnt3++;
		($SP3{$cnt3},$GENE3{$cnt3},$STRAND7{$cnt3},$START7{$cnt3},$END7{$cnt3},$TYPE7{$cnt3})=(split /\s+/,$_)[0,1,2,3,4,5];
	}
	foreach (keys %SP3){
		if ($_==1 and $START7{$_}!=1){
			unshift @output4,$SP3{$_}."\t"."start".'-'.$GENE3{$_}."\t"."?"."/".$STRAND7{$_}."\t"."1"."\t".($START7{$_}-1)."\t"."?"."/".$TYPE7{$_}."\n";
		}
	}
	foreach (1..($cnt3-1)) {
        $last0=$_-1;
		$last1=$_+1;
		$last2=$_+2;
		next if ((($END7{$_}+1) >= ($START7{$last1}-1)) and (($END7{$_}+1) < ($END7{$last1}-1)));
		next if (($_ > 1) and (($END7{$_}+1) < ($END7{$last0}-1)) and (($END7{$_}+1) < ($START7{$last2}-1)));
		if ((($END7{$_}+1) >= ($START7{$last1}-1)) and (($END7{$_}+1) >= ($END7{$last1}-1))){
    		push @output4,$SP3{$_}."\t".$GENE3{$_}.'-'.$GENE3{$last2}."\t".$STRAND7{$_}."/".$STRAND7{$last2}."\t".($END7{$_}+1)."\t".($START7{$last2}-1)."\t".$TYPE7{$_}."/".$TYPE7{$last2}."\n";
        }else{
    		push @output4,$SP3{$_}."\t".$GENE3{$_}.'-'.$GENE3{$last1}."\t".$STRAND7{$_}."/".$STRAND7{$last1}."\t".($END7{$_}+1)."\t".($START7{$last1}-1)."\t".$TYPE7{$_}."/".$TYPE7{$last1}."\n";
        }
	}
	foreach (keys %SP3){
		if ($_==$cnt3){
			push @output4,$SP3{$_}."\t".$GENE3{$_}.'-'."end"."\t".$STRAND7{$_}."/"."?"."\t".($END7{$_}+1)."\t".$length."\t".$TYPE7{$_}."/"."?"."\n";
		}
	}
	@output3=();


	#extract_IGS
	my (%SP4,%GENE4,%STRAND8,%START8,%END8,%TYPE8,$seq2);
	my $cnt4=0;
	open(my $out_noncoding,">","$filename_base\_intergenic.fasta");
	while (@fasta2){
		my $header=shift @fasta2;
		$seq2=shift @fasta2;
	}
	foreach (@output4){
		chomp;
		$cnt4++;
		($SP4{$cnt4},$GENE4{$cnt4},$STRAND8{$cnt4},$START8{$cnt4},$END8{$cnt4},$TYPE8{$cnt4})=(split /\s+/,$_)[0,1,2,3,4,5];
		my $str=substr($seq2,($START8{$cnt4}-1),($END8{$cnt4}-$START8{$cnt4}+1));
		print $out_noncoding ">".$GENE4{$cnt4}."_".$SP4{$cnt4}."\n".$str."\n";
	}
	@output4=();
	close $out_noncoding;
    #unlink "$filename_base\_intergenic.fasta";
}
