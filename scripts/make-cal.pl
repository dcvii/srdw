#!/usr/bin/perl
#
# AIX version
# updated - 20030311 - mb@mdcbowen.org
# for NISSAN-USA
#
######################

# this program creates the calendar perldb for the translation
# of fiscal periods in tokenfiles to calendar periods.


dbmopen(%cal, "calendar", 0666);
open (IN, "< cal.dat") || die "s.pl: cal file unspec.\n";

while (<IN>) {

	chop;
	@l = split('\t',$_,2);
	$cal{$l[0]} = $l[1];


}
close IN;
dbmclose(%cal);




## calendar record
