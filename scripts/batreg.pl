#!/usr/bin/perl
#
# AIX version
# updated - 20030311 - mb@mdcbowen.org
# for NISSAN-USA
#
######################

# manual modification of the registry

$rkey = shift @ARGV;
$new = shift @ARGV;
$func = "a";


if ($func =~ /^x/) {
	print "delete $rkey\n";
	dbmopen(%reg, "registry", 0666);
	$val = $reg{$rkey};	#read in, could be null
	if ($val) {
		print "$val DELETED\n";
		delete $reg{$rkey};
	} else {
		print "not found.\n";
	}
	dbmclose(%reg);

}

if ($func =~ /^c/) {
	print "create $rkey\n";
	dbmopen(%reg, "registry", 0666);
	$val = $reg{$rkey};	#read in, could be null
	$t = mbstamp(time());
	if ($val) {
		$reg{$rkey} = $new;
		print "$new CHANGED\n";
		open (OUT, ">> registry.log");
		print OUT "$rkey\t$new\n";
		close OUT;
	} else {
		$reg{$rkey} = $new;
		print "$new CREATED\n";
		open (OUT, ">> registry.log");
		print OUT "$rkey\t$new\n";
		close OUT;

	}
	dbmclose(%reg);

}


if ($func =~ /^a/) {
	print "add $rkey\n";
	dbmopen(%reg, "registry", 0666);
	$val = $reg{$rkey};	#read in, could be null
	if ($val) {
		$reg{$rkey} = $new;
		print "$new CHANGED\n";
		open (OUT, ">> registry.log");
		print OUT "$rkey\t$new\n";
		close OUT;
	} else {
		$reg{$rkey} = $new;
		print "$new ADDED\n";
		open (OUT, ">> registry.log");
		print OUT "$rkey\t$new\n";
		close OUT;

	}
	dbmclose(%reg);

}

&writeRegistry;

dbmclose(%reg);


sub writeRegistry {

	dbmopen(%reg, "registry", 0666);
	open (OUT, "> registry.txt");
	foreach $a (sort keys %reg) {
		print OUT "$a\t$reg{$a}\n";
	}

	dbmclose(%reg);
	close OUT;

	#system ("cat registry.txt");
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

## registry record
## key: company code (nmex, nmac..etc)
## record: environment | run code | posting period | timestamp  