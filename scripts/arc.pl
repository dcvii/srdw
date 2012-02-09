#!/usr/bin/perl
#
# AIX version 
# updated - 20030311 - mb@mdcbowen.org
# for NISSAN-USA
#
######################



$file = shift @ARGV; 
$file || die "usage: arc.pl filespec\n";
$infile = $file;
$alt = shift @ARGV;

if ($alt) {
	# print "i saw $alt\n";
	$stamp = $alt;
	} else {
	$stamp = mbstamp(time);
}


$file =~/(.*)\W(.*)/;

#print "pre: $pre\n";
#print "1: $1\n";
#print "2: $2\n";
#print "matched string: $&\n";


$ofile = "$1-$stamp.$2";
$outfile = "archive/$ofile";

# move it

if (-e $infile) {
	
	print "arc.pl: archiving $infile..\n";
	$cmd = "mv $infile $outfile";
	#print "$cmd\n";
	system ($cmd);
		
	} else {
	print "arc.pl: file not found.\n";
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

