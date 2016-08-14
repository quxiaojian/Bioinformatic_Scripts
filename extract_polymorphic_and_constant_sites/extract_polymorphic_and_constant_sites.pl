#!/usr/bin/perl -w
use strict;
use Data::Dumper;
#array of hash plus transposed matrix(two-dimensional array)

my $input_file="input.fasta";
my $output_file1="site_polymorphic.fasta";
my $output_file2="stie_constant.fasta";
open(my $input,"<",$input_file);
open(my $output1,">",$output_file1);
open(my $output2,">",$output_file2);

my ($header,$sequence,$length,@id,@site);
while (defined ($header=<$input>) && defined ($sequence=<$input>)) {
	chomp ($header,$sequence);
	$length=length $sequence;
	push @id,$header;

    my $rec={};
	for (0..$length-1){
		$rec->{$_}=substr($sequence,$_,1);
	}
    push @site,$rec;#array of hash
}

my @array;#array of array_ref,all sites,first array_ref is first column
for my $m (0..$length-1){
	for my $i (0..$#site) {
		for my $j (sort {$a <=> $b} keys %{$site[$i]}) {
			push @{$array[$j]},$site[$i]{$j} if $j==$m;
		}
	}
}

my @polymorphic_array;#polymorphic sites,first array_ref is fisrt column
for my $column (0..$#array){
	for my $nucleotide ($array[$column]){
		my %seen;
		if (grep{$_ ne $nucleotide->[0]} @$nucleotide) {
			push @polymorphic_array,[@$nucleotide];
			delete $array[$column];#undefined
		}
	}
}
@array=grep {defined $_} @array;#constant sites,remove undefined elements


#polymorphic sites,first array_ref is first row
my @transposed_polymorphic_array=map {my $x=$_;[map {$polymorphic_array[$_][$x]} (0..$#polymorphic_array)]} (0..$#{$polymorphic_array[0]});
for (0..(@id-1)){
	print $output1 $id[$_],"\n",@{$transposed_polymorphic_array[$_]},"\n";
}

#constant sites,first array_ref is first row
my @transposed_array=map {my $x=$_;[map {$array[$_][$x]} (0..$#array)]} (0..$#{$array[0]});
for (0..(@id-1)){
	print $output2 $id[$_],"\n",@{$transposed_array[$_]},"\n";
}

close $input;
close $output1;
close $output2;
