# !/usr/bin/perl


($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$a = time;


@months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");


print "$months[$mon] $mday\n";