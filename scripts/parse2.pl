# !/usr/bin/perl

## ok

## get environment
open (ENV, "< env.dat") || die "parse1.pl: environment file missing.\n";
$env = <ENV>;
chop $env;
close ENV;

open (DISK, "< disk.dat") || die "parse1.pl: disk file missing.\n";
$disk = <DISK>;
chop $disk;
close DISK;


$b = "\\";
$app = shift(@ARGV) || "RFIN";

$esspath = "/".$disk."01/vendors/essbase/app/$app/";
$slog = $app.".log";

$file = $esspath.$slog;
#print "opening $slog..";
open (LOG, $file) || die "can't find $file.\n";
while (<LOG>) {
	chop;
	if (/1001065/) {
		$re++;
		/Main\/(\w+)/;
		# print "$1\n";
		 $user{$1}++;
	}
	if (/1020055/) {
		$se++;
		/Main\/(\w+)/;
		# print "$1\n";
		 $user{$1}++;
	}

}

#print "done.\n";
print "$app stats:\n";
print "$re regular queries.\n";
print "$se spreadsheet queries.\n\n";
close (LOG);

foreach $a (sort keys %user) {
	print  "$a\t\t$user{$a}\n";
}
print "---\n";







