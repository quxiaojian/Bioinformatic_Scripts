#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","input");
my $pattern=&default(".fasta","pattern");
my $list=&default("list.txt","list");
my $outdir=&default("output","output");

my $osname=$^O;
if ($osname eq "MSWin32") {
	system("del/f/s/q $outdir") if (-e $outdir);
}elsif ($osname eq "cygwin") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "linux") {
	system("rm -rf $outdir") if (-e $outdir);
}elsif ($osname eq "darwin") {
	system("rm -rf $outdir") if (-e $outdir);
}
mkdir ($outdir) if (!-e $outdir);

my $i=1;
while (my $infile = glob("$indir/*$pattern")) {
	printf ("(%d)\tNow processing file => %s\t",$i++,$infile);
	my $outfile = $outdir."/".substr($infile,index($infile,"/")+1);
	my %header;
	open (my $header,"<",$list);
	while(<$header>) {
		#chomp;
		$_=~ s/\r|\n//g;
		$header{$_} += 1;
	}
	close $header;
	open (my $fasta,"<",$infile);
	open (my $output,">","$outfile");
	my ($head,$seq);
	while (defined ($head=<$fasta>) and defined ($seq=<$fasta>)) {
		$head=~ s/\r|\n//g;
		$seq=~ s/\r|\n//g;
		my $id=$1 if $head =~ /^>(\S+)/;
		print $output ">$id\n$seq\n" if (exists($header{$id}));
	}
	close $fasta;
	close $output;
	printf("Output file => %s\n",$outfile);
}


##function
sub argument{
	my @options=("help|h","input|i:s","pattern|p:s","list|l:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'pattern'}){
		print "***ERROR: No suffix pattern is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'list'}){
		print "***ERROR: No list filename is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'output'}){
		print "***ERROR: No output directory is assigned!!!\n";
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

    extract_sequences_from_fasta_matrix_based_on_headers.pl

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

    extract sequences from fasta matrix based on headers

=head1 SYNOPSIS

    extract_sequences_from_fasta_matrix_based_on_headers.pl -i -p -l -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory.
    [-p -pattern]      required: (default: .fasta) suffix pattern.
    [-l -list]         required: (default: list.txt) list filename.
    [-o -output]       required: (default: output) output directory.

=cut
