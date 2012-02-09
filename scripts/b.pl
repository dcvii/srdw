#!/usr/bin/perl
#
# AIX version
# updated - 20030311 - mb@mdcbowen.org
# for NISSAN-USA
#
######################


$exval=0;
$cmd = shift @ARGV;
$cmd .= "> a.out";
system($cmd);
open (TMP, "a.out");
while (<TMP>) {
	if (/ERROR/) {
		$exval = 1;
	}
}
close TMP;
print "$exval";
