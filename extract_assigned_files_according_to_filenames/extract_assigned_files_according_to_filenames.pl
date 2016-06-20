#!/usr/bin/perl -w
use strict;
use File::Copy;
$|=1;

print "Please input your source dir: ";
chomp (my $source=<STDIN>);
opendir (my $indir,$source);
my @filenames=grep /.+\.nex$/,readdir $indir;
my %hash;

foreach (@filenames) {
	$hash{$_}=1;
}

print "Please input your destination dir: ";
chomp (my $destination=<STDIN>);
system ("rm -rf $destination") if (-e $destination);
system ("mkdir $destination") if (! -e $destination);

print "Please input your list file: ";
chomp (my $list=<STDIN>);
open (my $input,"<",$list);

print "No match in list file:\n";
while (<$input>){
	chomp;
	if (exists $hash{$_}){
		$hash{$_}++;
		copy ("$source/$_","$destination/$_");
	}else{
		print "$_\n";
	}
}

open (my $output,">","No_match.txt");

foreach (sort keys %hash){
	print $output "$_\n" if ($hash{$_}==1);
}

closedir $indir;
close $input;
close $output;
