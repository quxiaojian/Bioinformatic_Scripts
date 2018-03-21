#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;
#array of hash plus transposed matrix(two-dimensional array)

my $global_options=&argument();
my $input_file=&default("input","input");
my $output_file1=&default("output1","output1");
my $output_file2=&default("output2","output2");

open(my $input,"<",$input_file);
open(my $output1,">",$output_file1);
open(my $output2,">",$output_file2);

my ($header,$sequence,$length,@id,@site);
while (defined ($header=<$input>) && defined ($sequence=<$input>)) {
	#chomp ($header,$sequence);
	$header=~ s/\r|\n//g;
	$sequence=~ s/\r|\n//g;
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


##function
sub argument{
	my @options=("help|h","input|i:s","output1|o1:s","output2|o2:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input filename is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output1'}){
		print "***ERROR: No output1 filename is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output2'}){
		print "***ERROR: No output2 filename is assigned!!!\n";
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

    extract_polymorphic_and_constant_sites.pl

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

    extract polymorphic and constant sites

=head1 SYNOPSIS

    extract_polymorphic_and_constant_sites.pl -i -o1 -o2
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input.fasta) input filename of matrix.
    [-o1 -output1]     required: (default: polymorphic.fasta) output1 filename of polymorphic sites matrix.
    [-o2 -output2]     required: (default: constant.fasta) output2 filename of constant sites matrix.

=cut
