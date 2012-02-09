#!/usr/bin/perl

# splits a file into two
# 
# mbowen - 20030421.1500
# mb@mdcbowen.org
###########################################
#
# handles ACT6, BUD6, ELIM

# inputstuf
$infile = shift @ARGV; 
$infile || die "usage: sp.pl filespec\n";
print "sp.pl: splitting $infile..";

$out1 = shift @ARGV;
$out1 || die "usage: sp.pl filespec\n";

$out2 = shift @ARGV;
$out2 || die "usage: sp.pl filespec\n";


## get environment
open (ENV, "< env.dat") || die "sp.pl: environment file missing.\n";
$env = <ENV>;
chop $env;
close ENV;

open (DISK, "< disk.dat") || die "sp.pl: disk file missing.\n";
$disk = <DISK>;
chop $disk;
close DISK;


if ($infile =~ m/\_e\.txt/) {
	$f = 6; 
	print "sp.pl: elimination split.\n";
	} else {
	$f = 10;
	print "sp.pl: normal split.\n";
}


## big parse
open (IN, $infile) || die "sp.pl: can't open $infile.\n";
open (OUT1, "> $out1");
open (OUT2, "> $out2");

while (<IN>) {
	chop;
	$line = $_;
	@fields = split ('\|',$_);
	if ($fields[$f] =~ /^[1-3]/) {
		print OUT1 "$line\n";
	} else {
	print OUT2 "$line\n";
	}
	
}	
		

close OUT1;
close OUT2;
close IN;
print "done.\n";