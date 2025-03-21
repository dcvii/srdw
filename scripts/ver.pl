#!/usr/bin/perl

# read in a .ver file and then spit it back out incremented and timestamped. you get 999 builds only.

$version = shift @ARGV; 
$version || die "usage: ver.pl filespec\n";
print "parsing $version..";


$outfile = "> $version";

if (-e $version) {
open (IN, $version) || die "ver.pl: cant open $version\n";
} else { makefile($version);
	open (IN, $version); }


while (<IN>) {

	chop;
	$line[$i] = $_;
	if (/Build/) {
		@inline = split (':',$_,2)
	}

}


$appname = $inline[0];
# print "appname is $appname\n";
$build = $inline[1];
$buildnum = substr($build, -3);
# print "buildnum is $buildnum\n";
$buildnum++;

$outline = "$appname:Build $buildnum";
print "$outline\n";

close IN;


open (OUT, $outfile);
$st = mbstamp(time());
print OUT "$outline\n$st\n\n";
close OUT;
print "done.\n";

sub makefile {
	## this sub will make a ver file if one is not found
	## the appname will default to the first 4 bytes of the filenamd
	
	local $fspec = $_[0];
	
	print "not found. creating file.\n";
	$first = substr($fspec,0,4);
	#print "$first\n";
	$b = "000";
	$t = mbstamp(time());
	open (OUT, "> $fspec");
	print OUT "$first:Build $b\n$t\n\n";
	close OUT;
	
		
}


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
