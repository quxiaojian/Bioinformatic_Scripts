#!/usr/bin/perl
use strict;
use Term::ProgressBar;

open (my $genename,"<","genename.txt");
chomp (my @names=<$genename>);
close $genename;

open (my $file,"<","PCG_M.fasta");
my $seqcount = 0;
while (<$file>) {
	$seqcount++ if(/^>/);
}
my $progress=Term::ProgressBar->new({
	count		=>	$seqcount,
	name		=>	'Processing',
	major_char	=>	'=',			# default symbol of major progress bar
	minor_char	=>	'*',			# default symbol of minor progress bar
	ETA			=>	'linear',		# evaluate remain time: undef (default) or linear
	#term_width	=>	100,			# breadth of terminal, full screen (default)
	#remove		=>	0,				# whether the progress bar disappear after the end of this script or not? 0 (default) or 1
	#fh			=>	\*STDOUT,		# \*STDERR || \*STDOUT
});
$progress->lbrack('[');				# left symbol of progress bar
$progress->rbrack(']');				# right symbol of progress bar
$progress->minor(0);				# close minor progress bar
#$progress->max_update_rate(0.5);	# minumum gap time between two updates (s)


my $outdir="output";
system ("rm -rf output") if (-e $outdir);
system ("mkdir output") if (! -e $outdir);
my $count=0;
my $update=0;
seek ($file,0,0);

while (chomp (my $header=<$file>) && chomp (my $sequence=<$file>)) {
	foreach my $name (@names) {
		if ($header=~ m/$name/) {
			open (my $fh,">>","$outdir/$name.fasta");
			print $fh "$header\n$sequence\n";
			close $fh;
		}
	}
	$count++;
	$update=$progress->update ($count) if ($count > $update);
}
$progress->update ($seqcount) if ($seqcount >= $update);
close $file;
