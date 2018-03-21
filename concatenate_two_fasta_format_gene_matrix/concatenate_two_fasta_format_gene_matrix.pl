#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;
$|=1;

my $global_options=&argument();
my $indir=&default("input","input");
my $pattern1=&default("_1.fasta","pattern1");
my $pattern2=&default("_PUIS.fasta","pattern2");
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

my $i=0;
my $infile1;
my $infile2;
while (defined ($infile1=glob($indir."/*$pattern1")) and defined ($infile2=glob ($indir."/*$pattern2"))){
	my $filename1=substr ($infile1,index ($infile1,"/")+1);
	my $left1=substr ($filename1,0,index ($filename1,"_"));
	#my $right1=substr ($filename1,index ($filename1,"_")+1,-6);
	my $filename2=substr ($infile2,index ($infile2,"/")+1);
	my $left2=substr ($filename2,0,index ($filename2,"_"));
	#my $right2=substr ($filename2,index ($filename2,"_")+1,-6);

	printf("(%d)\tNow processing file => %s\n",++$i,"$infile1 and $filename2");
	if ($left1 eq $left2) {
		open (my $input1,"<",$infile1);
		open (my $input2,"<",$infile2);
		open (my $output,">","$outdir/$left1\_slow.fasta");
    	my %hash;

		while (defined (my $header1=<$input1>) && defined (my $seq1=<$input1>)) {
			chomp ($header1,$seq1);
			my $id1=$1 if $header1=~ /^(>\S+)/;
			$hash{$id1}=$seq1;
		}
		while (defined (my $header2=<$input2>) && defined (my $seq2=<$input2>)) {
			chomp ($header2,$seq2);
			my $id2=$1 if $header2=~ /^(>\S+)/;
			$hash{$id2}.=$seq2;
		}
		foreach my $key (sort {$a cmp $b} keys %hash){
			print $output "$key\n$hash{$key}\n";
		}
		close $input1;
		close $input2;
		close $output;
	}
}


##function
sub argument{
	my @options=("help|h","input|i:s","pattern1|p1:s","pattern2|p2:s","output|o:s");
	my %options;
	GetOptions(\%options,@options);
	exec ("pod2usage $0") if ((keys %options)==0 or $options{'h'} or $options{'help'});
	if(!exists $options{'input'}){
		print "***ERROR: No input directory is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'pattern1'}){
		print "***ERROR: No pattern1 is assigned!!!\n";
		exec ("pod2usage $0");
	}elsif(!exists $options{'pattern2'}){
		print "***ERROR: No pattern2 is assigned!!!\n";
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

    concatenate_two_fasta_format_gene_matrix.pl

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

    concatenate two fasta format gene matrix

=head1 SYNOPSIS

    concatenate_two_fasta_format_gene_matrix.pl -i -p1 -p2 -o
    Copyright (C) 2018 Xiao-Jian Qu
    Please contact <quxiaojian@mail.kib.ac.cn>, if you have any bugs or questions.

    [-h -help]         help information.
    [-i -input]        required: (default: input) input directory name.
    [-p1 -pattern1]    required: (default: _1.fasta) match pattern.
    [-p2 -pattern2]    required: (default: _PUIS.fasta) match pattern.
    [-o -output]       required: (default: output) output directory name.

=cut
