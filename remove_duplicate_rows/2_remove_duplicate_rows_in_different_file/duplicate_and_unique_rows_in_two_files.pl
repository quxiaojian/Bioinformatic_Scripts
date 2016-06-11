#!/usr/bin/perl -w
use strict;

my $filenameA="PCG_V_row.txt";
my $filenameB="PCG_row.txt";

open (my $fileA,"<",$filenameA);
my (%hash,$i);
while(my $row=<$fileA>){
	chomp $row;
	$hash{$row}=$i++;
}

open (my $fileB,"<",$filenameB);
my @array;
print "Duplicated rows in files $filenameA and $filenameB!\n";
while(my $line=<$fileB>){
	chomp $line;
	unless (defined $hash{$line}){
		push (@array,"$line\t$.");
	}else{
		print "$line in line number ".($hash{$line}+1)." ($filenameA) and $. ($filenameB)\n";
		$hash{$line}=0;
	}
}
if ((scalar @array)==0) {
	print "0 lines\n";
}

my $countA=0;
my %rhash=reverse %hash;
print "Unique rows in file $filenameA!\n";
foreach my $key (sort keys %rhash) {
	if ($key>0) {
        print "$rhash{$key} in line number ".($key+1)."\n";
		$countA++;
    }
}
print "$countA lines\n";

print "Unique rows in file $filenameB!\n";
my $countB=scalar @array;
foreach my $element (@array){
	my @newarray=(split/\s+/,$element);
	my $number=pop @newarray;
	my $scalar=join ("\t",@newarray);
	print $scalar." in line number $number\n";
}
print "$countB lines\n";

if ($countA==0 and $countB==0 ){
	print "Two files are identical!\n";
}
