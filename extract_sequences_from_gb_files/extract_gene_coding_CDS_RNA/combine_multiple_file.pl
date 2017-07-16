#!/usr/bin/perl -w
use strict;
use Data::Dumper;
$|=1;

print "Please type your directory: ";
my $directory=<STDIN>;
chomp $directory;

opendir(my $dir,$directory);
my @directory = readdir $dir;
close $dir;
foreach my $file (@directory){
	if($file=~/_gene.fasta/){
		open (my $input,"<","$directory/$file");
		open (my $output,">>","db_gene.fasta");
		while(<$input>){
			print $output $_;
		}
		close $input;
		close $output;
	}
	if($file=~/_coding.fasta/){
		open (my $input,"<","$directory/$file");
		open (my $output,">>","db_coding.fasta");
		while(<$input>){
			print $output $_;
		}
		close $input;
		close $output;
	}
	if($file=~/_CDS.fasta/){
		open (my $input,"<","$directory/$file");
		open (my $output,">>","db_CDS.fasta");
		while(<$input>){
			print $output $_;
		}
		close $input;
		close $output;
	}
	if($file=~/_RNA.fasta/){
		open (my $input,"<","$directory/$file");
		open (my $output,">>","db_RNA.fasta");
		while(<$input>){
			print $output $_;
		}
		close $input;
		close $output;
	}
}
