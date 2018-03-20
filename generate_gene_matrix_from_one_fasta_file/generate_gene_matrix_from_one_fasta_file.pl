#!/usr/bin/perl
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $fastafilename=&default("fasta","fasta");
my $genefilename=&default("gene","gene");
my $outdir=&default("output","output");

open (my $genename,"<",$genefilename);
my @names;
while (<$genename>) {
	$_=~ s/\r|\n//g;
	push @names,$_;
}
close $genename;

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

open (my $file,"<",$fastafilename);
my ($header,$sequence);
while (defined ($header=<$file>) and defined ($sequence=<$file>)) {
	$header=~ s/\r|\n//g;
	$sequence=~ s/\r|\n//g;
	foreach my $name (@names) {
		if ($header=~ m/$name/) {
			open (my $fh,">>","$outdir/$name.fasta");
			print $fh "$header\n$sequence\n";
			close $fh;
		}
	}
}
close $file;


##function##
sub argument{
	my @options=("help|h","fasta|f:s","gene|g:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'fasta'}){
		print "***ERROR: No fasta filename is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'gene'}){
		print "***ERROR: No gene filename is assigned!!!\n";
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

    generate_gene_matrix_from_one_fasta_file.pl

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

    generate gene matrix from one fasta file

=head1 SYNOPSIS

    generate_gene_matrix_from_one_fasta_file.pl -f -g -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-f -fasta]        required: (default: fasta) fasta filename containing gene sequences from multiple species.
    [-g -gene]         required: (default: gene) gene filename.
    [-o -output]       required: (default: output) output directory.

=cut
