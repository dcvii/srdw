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
print "opening $slog..";
open (LOG, $file) || die "can't find $file.\n";
while (<LOG>) {
	chop;
	if (/c Elapsed Time/) {
		$ncalcs++;
		/.{27}(\b\d*\b)/;
		# print "$&\n";
	}
	if (/Extractor Elapsed Time/) {
		$nq++
	}

}

print "done.\n";
print "$app stats:\n";
print "$nq queries.\t";
print "$ncalcs calcs.\n";
close (LOG);

