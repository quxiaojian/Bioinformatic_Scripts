#!/usr/bin/perl
use strict;
use Data::Dumper;

my $filename="header.txt";
open (my $sp,"<",$filename);
my @more;

while (chomp (my $line=<$sp>)) {
    push @more,$line;
}

my $indir="input";
my $i=0;
my $infile;
my %hash;

while (defined ($infile=glob ($indir."/*.fasta"))){
	printf("(%d)\tNow processing file => %s\n",++$i,$infile);
	open (my $input,"<",$infile);
	open (my $output,">","all.fasta");
	my @less;
	my @difference;
	my $length;

	while (chomp (my $row=<$input>) && chomp (my $sequence=<$input>)) {
		my $id=$1 if ($row=~ /^(>\S+)/);
		push @less,$id;
		$length=length $sequence;
	}

	my %hash_difference=map {($_, 1)} @less;
	@difference=grep {! $hash_difference{$_}} @more;

	foreach my $element (@difference){
		my $gap="-" x $length;
		$hash{$element}.=$gap;
	}

	seek $input,0,0;
	while (chomp (my $header=<$input>) && chomp (my $seq=<$input>)) {
		my $id=$1 if $header=~ /^(>\S+)/;
		$hash{$id}.=$seq;
	}

	foreach my $key (sort {$a cmp $b} keys %hash){
		print $output "$key\n$hash{$key}\n";
	}
}
