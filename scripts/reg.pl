#!/usr/bin/perl
#
# AIX version
# updated - 20030311 - mb@mdcbowen.org
# for NISSAN-USA
#
######################

# this proc will eyeball a tokenfile and interpret the date
# it will then store the date and the company name as well as
# a time stamp into a database and/or flatfile. this will let
# us know exactly which files have been processed and when.

# this script is called by prepoll.sh which is triggered regularly
# by the watcher.sh. the context is the rfin assymetrical data
# preparation.



$xapp = shift @ARGV;

$comp = shift @ARGV;
$comp || die "usage: register.pl filespec\n";
$infile = $comp.".token";

$ftype = shift@ARGV;
$ftype =~ tr/a-z/A-Z/;


$go = 0;
open (TOKEN, "< $infile") || die "reg.pl: token file unspec.\n";

while (<TOKEN>) {

	chop;
	if (/00/) {
		$line = $_;
		$go = 1;
	}
}
close TOKEN;


## get environment
open (ENV, "< env.dat") || die "reg.pl: environment file missing.\n";
$env = <ENV>;
chop $env;
close ENV;

open (DISK, "< disk.dat") || die "reg.pl: disk file missing.\n";
$disk = <DISK>;
chop $disk;
close DISK;



# print "i see $env.\n";

&updateRegistry($xapp, $infile, $ftype, $line, $go);
&writeRegistry;



sub mbstamp {

	## be smart about what you pass in or else you get 19691231.180000
	## mbstamp expects time();

        local $intime = $_[0];
        $l = localtime($intime);

        #print "$l\n";

        %mos =
("Jan","01","Feb","02","Mar","03","Apr","04","May","05","Jun","06",

"Jul","07","Aug","08","Sep","09","Oct","10","Nov","11","Dec","12");

        $cent = substr($l,-4);
        #print "$cent\n";

        $hrs = substr($l,11,8);
        $hrs =~ s/\://g;
        #print "$hrs\n";

        $nmo = substr($l,4,3);
        $mo = $mos{$nmo};
        #print "$mo\n";

        $da = substr($l,8,2);
        $da =~ s/\D/0/;

        $outtime = "$cent$mo$da-$hrs";
        return $outtime;
}


sub updateRegistry {

	local $xapp = $_[0];
	local $tfile = $_[1];
	local $ftype = $_[2];
	local $stamp = $_[3];
	local $ok = $_[4];

	$tfile =~/(.*)\W(.*)/;

	#print "1: $1\n";
	#print "2: $2\n";
	#print "matched string: $&\n";

	$a = mbstamp(time);
	if (not $ok) {
		$stamp = "xxxx-xx";
		print "empty (defective) token.\n";
		# $stamp = findStamp (
	}

	# open the hash file
	dbmopen(%reg, "registry", 0666);

	$rkey = "$xapp:$1:$ftype";

	$val = $reg{$rkey};	#read in, could be null

	if ($val) {
		#print "i see $val\n";
		@rec = split (':',$val,5);
		$run = substr($rec[2],3,3);

		#print "run is $run\n";
		$run++;

		$record = "$env:$xapp:"."Run"."$run:$stamp:$a";

	} else {
		# create first record
		# print "new creation.\n";
		$record = "$env:$xapp:"."Run000:$stamp:$a";
	}

	$reg{$rkey} = $record;
	dbmclose(%reg);

	$msg = "--reg.pl--\n$rkey \t $record\n";
	print "$msg";
	&notify ("$rkey\t$record");

	open (OUT, ">> registry.log");
	print OUT "$rkey\t$record\n";
	close OUT;

	$cmd = "cp -p registry.log ../logs/registry_activity.log";
	system ($cmd);


}


sub writeRegistry {

	dbmopen(%reg, "registry", 0666);
	open (OUT, "> registry.txt");
	foreach $a (sort keys %reg) {
		print OUT "$a\t$reg{$a}\n";
	}

	dbmclose(%reg);
	close OUT;
}


sub findStamp {


	$rutdir="/$disk01/vendors/essbase/";
	$inpdir="/$disk03/essbase/rdwmr/input/"	;


	open (DATA, "< $dfile");
	close;

}

sub notify {

	my $msg = shift @_;
	$names = "bowenm\@nmc.nna";

	$cmd = "echo $msg | mailx -s '$env Registry Results' $names";
	system ("$cmd");
}

## registry record
## key: company code (nmex, nmac..etc)
## record: environment | app | run code | posting period | timestamp
#  (delimiter is ':')
#
