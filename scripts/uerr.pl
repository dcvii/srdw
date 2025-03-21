#!/usr/bin/perl

# make unique list of errors in blah.err
# unique errors for essbase log files.
# mbowen - 20021101

$errfile = shift @ARGV; 
$errfile || die "usage: uerr.pl filespec\n";
print "parsing $errfile..";

# $errfile = "b_chan.err";
$outfile = "> $errfile".".u";

open (IN, $errfile) || die "no errors created.\n";
open (OUT, $outfile);
while (<IN>) {


	chop;
	if (/^\\/) {
		if(! $seen{$_} ) {
			print OUT "$_\n";
			$seen{$_}++;
		}
	}
}

close OUT;
close IN;
print "done.\n";