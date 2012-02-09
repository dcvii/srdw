#!/usr/bin/perl

# splits a file off for account series 1-3
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



if ($infile =~ m/\_e\.txt/) {
	#$f = 6;
	$f = 10; #change in eliminations format - mbowen 20030701
	print "sp.pl: elimination split.\n";
	} else {
	$f = 10;
	print "sp.pl: normal split.\n";
}


## big parse
open (IN, $infile) || die "sp.pl: can't open $infile.\n";
open (OUT1, "> $out1");

while (<IN>) {
	chop;
	$line = $_;
	@fields = split ('\|',$_);
	$acctkey = $fields[$f];

	$ok = 1;
	# new filters for useless stat accounts
	# 1. Balance sheet accounts (series 1-3)
	if ($acctkey =~ /^[^1-3]/) {$ok = 0;}

	# 2. Various stat accounts
	if ($acctkey =~ /^9[3-9]/) {$ok = 0;}
	#if ($acctkey =~ /^94/ {$ok = 0}
	#if ($acctkey =~ /^95]/ {$ok = 0}
	#if ($acctkey =~ /^92[^5]/ {$ok = 0}
	if ($ok = 1) {
		print OUT1 "$line\n";
	}

}


close OUT1;
close IN;
print "done.\n";