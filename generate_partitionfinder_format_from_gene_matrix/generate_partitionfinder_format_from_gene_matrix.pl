#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","input");
my $output=&default("output","output");
my $pattern=&default(".phy","pattern");

my $i=0;
my ($infile,@array);
while (defined($infile = glob($indir."/*$pattern"))) {
	my $genename=$infile;
	$genename=~ s/$pattern//g;
	$genename=substr($genename,rindex($genename,"\/")+1);
	printf("(%d)\tNow processing file => %s\n",++$i,$infile);
	open (my $input,"<",$infile);
	if ($infile=~ /\.phy/) {
		while (my $row=<$input>) {
			#chomp $row;
			$row=~ s/\r|\n//g;
			if ($row=~ /^\s(\d+)\s(\d+)/) {
				push @array,"$genename\t$2";
			}
		}
	}elsif ($infile=~ /\.fa/) {
		my ($header,$sequence,$length);
		my $j=0;
		while (defined ($header=<$input>) and defined ($sequence=<$input>)) {
			$header=~ s/\r|\n//g;
			$sequence=~ s/\r|\n//g;
			$length=length $sequence;
			push @array,"$genename\t$length";
			$j++;
			last if ($j > 0);
		}
	}
	close $input;
}

my $sum=0;
open(my $out,">",$output);
foreach my $line (@array) {
	my ($gene,$length)=split(/\s+/,$line);
	$sum=$sum+$length;
	my $sumlength=$sum+1-$length;
	print $out "$gene = $sumlength-$sum;\n";
}
close $out;


##function
sub argument{
	my @options=("help|h","input|i:s","output|o:s","pattern|p:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output filename is assigned!!!\n";
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

    PGA.pl Plastid Genome Annotation

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

    Plastid Genome Annotation

=head1 SYNOPSIS

    PGA.pl -r -t [-i -p -q -o -f -l]
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-r -reference]    required: (default: reference) input directory name containing GenBank-formatted file(s) that from the same or close families.
    [-t -target]       required: (default: target) input directory name containing FASTA-formatted file(s) that will be annotated.
    [-i -ir]           optional: (default: 1000) minimum allowed inverted-repeat (IR) length.

=cut
