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
$docal = 0;


## get environment
open (ENV, "< env.dat") || die "tk.pl: environment file missing.\n";
$env = <ENV>;
chop $env;
close ENV;

open (DISK, "< disk.dat") || die "tk.pl: disk file missing.\n";
$disk = <DISK>;
chop $disk;
close DISK;

if ($docal) {
	$calfile = "/".$disk."03/essbase/rdwmr/scripts/calendar";
	dbmopen(%cal, $calfile, 0666);
}


$line = (<TOKEN>);
if ($line =~ m/([0-9]{4})([0-9]{2})/) {
	# odd tokenfile
	$a = "$1-$2";
	$k = $1.$2; }
	elsif ($line =~ m/([0-9]{4})-([0-9]{2})/) {
		# normal tokenfile
		chop $line;
		$a = $line;
		$k = $1.$2;

	} else {
		#bad token! bad token!
		$a = "bad-token";
		$bad=1;
		&notify ($infile);
}

if ($docal) {

	if ($bad) {
		print "$a";
		} else {
		 print $cal{$k};
		 dbmclose(%cal);
	}
} else {
	print "$a";
}


sub notify {

	my $msg = shift @_;
	$names = "bowenm\@nmc.nna";

	$cmd = "cat $msg | mailx -s '$env Bad Token' $names";
	system ("$cmd");
}


### updates
# 20030529 - mbowen@mdcbowen.org
#          - convert all tokens via the calendar file, not just dev

# 20030602 - now change it back

