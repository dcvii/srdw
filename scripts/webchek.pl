#!/usr/bin/perl
#
# AIX version
#
# for NISSAN-USA
#
######################

# this script checks the reponse header from the checkReportsServer.pl
# returns 0 if ok, 1 for an error.


$infile = shift @ARGV;
open (TOKEN, "< $infile");

$a = 0;
$strHTTPResponse = '200 OK';


$line = (<TOKEN>);
if ($line =~ m/$strHTTPResponse/) {
	# HTTP Response is ok. Websphere is running
	# print "$line\n";
	$a = 0;
        # &notifygood ($infile);
         die $a;
	} else {
		# something is wrong
		$a = 1;
		$bad=1;
		&notifybad ($infile);
                die $a;
}


sub notifybad {

	my $msg = shift @_;
	$names = "schwabj\@nmc.nna, mcdougm\@nmc.nna";

	$cmd = "cat $msg | mailx -s 'QA Reports server is not reponding' $names";
	system ("$cmd");
}

sub notifygood {

        my $msg = shift @_;
        $names = "schwabj\@nmc.nna, mcdougm\@nmc.nna";

        $cmd = "cat $msg | mailx -s 'QA Reports server is reponding' $names";
        system ("$cmd");
}

