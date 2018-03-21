#!/usr/bin/perl
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","input");
my $pattern=&default(".fasta","pattern");
my $outputfilename=&default("output.fasta","output");

my ($inputfile,%unique);
while (defined ($inputfile=glob ($indir."/*$pattern"))){
	open (my $in,"<",$inputfile);
	my $row;
	while (defined ($row=<$in>)) {
		if ($row=~ /^>(\S+)/) {
			$unique{$1}++;
		}
	}
	close $in;
}
my @more=(keys %unique);

my $i=0;
my ($infile,%hash);
while (defined ($infile=glob ($indir."/*$pattern"))){
	printf("(%d)\tNow processing file => %s\n",++$i,$infile);
	open (my $input,"<",$infile);
	open (my $output,">",$outputfilename);
	my ($header,$sequence,$length,@less);
	while (defined ($header=<$input>) and defined ($sequence=<$input>)) {
		$header=~ s/\r|\n//g;
		$sequence=~ s/\r|\n//g;
		$length=length $sequence;
		my $id=$1 if ($header=~ /^>(\S+)/);
		push @less,$id;
	}

	my %hash_difference=map {($_, 1)} @less;
	my @difference=grep {! $hash_difference{$_}} @more;
	foreach my $element (@difference){
		my $gap="-" x $length;
		$hash{$element}.=$gap;
	}

	seek $input,0,0;
	my ($head,$seq);
	while (defined ($head=<$input>) and defined ($seq=<$input>)) {
		$head=~ s/\r|\n//g;
		$seq=~ s/\r|\n//g;
		my $id=$1 if $head=~ /^>(\S+)/;
		$hash{$id}.=$seq;
	}

	foreach my $key (sort {$a cmp $b} keys %hash){
		print $output ">$key\n$hash{$key}\n";
	}
	close $input;
	close $output;
}


##function
sub argument{
	my @options=("help|h","input|i:s","pattern|p:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'pattern'}){
		print "***ERROR: No pattern is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output filename is assigned!!!\n";
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

    concatenate_all_fasta_format_gene_matrix.pl

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

    concatenate all fasta format gene matrix

=head1 SYNOPSIS

    concatenate_all_fasta_format_gene_matrix.pl -i -p -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory name.
    [-p -pattern]      required: (default: .fasta) match pattern.
    [-o -output]       required: (default: output.fasta) output filename.

=cut
