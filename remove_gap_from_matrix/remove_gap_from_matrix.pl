#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
#array of hash plus transposed matrix(two-dimensional array)

my $global_options=&argument();
my $input_file=&default("input.fasta","input");
my $output_file1=&default("output.fasta","output");

#my $output_file2="gap.fasta";
open(my $input,"<",$input_file);
open(my $output1,">",$output_file1);
#open(my $output2,">",$output_file2);

my ($header,$sequence,$length,@id,@array);
while (defined ($header=<$input>) && defined ($sequence=<$input>)) {
	$header=~ s/\r|\n//g;
	$sequence=~ s/\r|\n//g;
	$length=length $sequence;
	push @id,$header;

	for (0..$length-1){
		push @{$array[$_]},substr($sequence,$_,1);
	}
}
#print Dumper \@array;

my @nongap_array;#nongap sites,first array_ref is fisrt column
for my $column (0..$#array){#1 of 36 columns
	for my $nucleotide ($array[$column]){#1 of 4 nt in each column
		my %seen;
		if ((grep{$_ eq "A"} @$nucleotide) or (grep{$_ eq "T"} @$nucleotide) or (grep{$_ eq "G"} @$nucleotide) or (grep{$_ eq "C"} @$nucleotide)) {
			push @nongap_array,[@$nucleotide];
			#delete $array[$column];#undefined
		}
	}
}
#print Dumper \@nongap_array;
#@array=grep {defined $_} @array;#gap sites,remove undefined elements


#nongap sites,first array_ref is first row
my @transposed_nongap_array=map {my $x=$_;[map {$nongap_array[$_][$x]} (0..$#nongap_array)]} (0..$#{$nongap_array[0]});
for (0..(@id-1)){
	print $output1 $id[$_],"\n",@{$transposed_nongap_array[$_]},"\n";
}

##gap sites,first array_ref is first row
#my @transposed_array=map {my $x=$_;[map {$array[$_][$x]} (0..$#array)]} (0..$#{$array[0]});
#for (0..(@id-1)){
	#print $output2 $id[$_],"\n",@{$transposed_array[$_]},"\n";
#}

close $input;
close $output1;
#close $output2;


sub argument{
	my @options=("help|h","input|i:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input file is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output file is assigned!!!\n";
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

    remove_gap_from_matrix.pl

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

    remove gap from matrix

=head1 SYNOPSIS

    remove_gap_from_matrix.pl -i -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input.fasta) input filename of alignment matrix.
    [-o -output]       required: (default: output.fasta) output filename of alignment matrix.

=cut
