# !/usr/bin/perl

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
@months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
$dat = "$months[$mon] $mday\n";

$app = shift(@ARGV) || "RFIN";
$dat = shift(@ARGV) || "$months[$mon] $mday";

$re = $se = $entries = 0;

#print "opening $slog..";
$file = "$app.log";
open (LOG, $file) || die "can't find $file.\n";
while (<LOG>) {
	chop;
	if (/$dat/) {
		$entries++;
		if (/1001065/) {
			$re++;
			#print "$test\n";
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
}

#print "done.\n";
print "$app stats:\n";
print "$entries matched records for $dat.\n";
print "$re regular queries.\n";
print "$se spreadsheet queries.\n\n";
close (LOG);

foreach $a (sort keys %user) {
	print  "$a\t\t$user{$a}\n";
}
print "---\n";







