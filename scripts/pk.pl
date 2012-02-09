#!/usr/bin/perl
#
# AIX version
# updated - 20030529 - mb@mdcbowen.org
# for NISSAN-USA
#
######################

# this proc will eyeball a tokenfile and interpret the date
# for prepoll.sh for return into a shell variable. this will
# direct the storage of the datafiles associated with the token.
#
# if the token has no data or incorrect data, a notification will
# be sent and the files will be plunked into a 'bad-token' directory.

# this script is called by prepoll.sh which is triggered regularly
# by the watcher.sh. the context is the rfin assymetrical data
# preparation.




$infile = shift @ARGV;
open (TOKEN, "< $infile");

#not sure about this... - 20030529 - mbowen
if ($infile =~ m/NMEX/) {
	$bad = 1;
}

## get environment
open (ENV, "< env.dat") || die "tk.pl: environment file missing.\n";
$env = <ENV>;
chop $env;
close ENV;

open (DISK, "< disk.dat") || die "tk.pl: disk file missing.\n";
$disk = <DISK>;
chop $disk;
close DISK;

$calfile = "/".$disk."03/essbase/rdwmr/scripts/calendar";
dbmopen(%cal, $calfile, 0666);


open (OUT, "> cal.txt");
foreach $a (sort keys %cal) {
	print OUT "$a\t$cal{$a}\n";
}

dbmclose(%cal);
close OUT;






### updates
# 20030529 - mbowen@mdcbowen.org
#          - convert all tokens via the calendar file, not just dev
