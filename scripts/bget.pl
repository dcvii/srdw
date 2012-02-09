#!/usr/bin/perl -w
# Basic webpage GET tool. Much simpler than LWP GET, but not as powerful.
# It only needs modules installed by default, however. Also emulating the
# headers of other browsers is well supported; setting Cookie: and Referer:
# headers is made simpler. AND this is much better at spying on headers
# since it dumps them literally and unmodified (particularly request
# headers), but does not follow redirects.
#
# 22 November 1999	B. Elijah Griffin / Eli the Bearded
use strict;
BEGIN { $ENV{PATH} = '/usr/ucb:/bin' }
use vars qw($EOL $url $tcpproto $nosignal $id $bv %headers $post $forcehost
	$refer $cookie $print_request $print_body $print_heads $user $long
 	$follow $waittime $benchmark $debug $autoname $lang $dirdefault
	$VERSION $LONG_VERSION_INFO);
use Socket;
use Carp;

$VERSION = '1.0';
$LONG_VERSION_INFO = 'initial: 22-Nov-1999; this: 15 Dec 2000';

$EOL = "\cm\cj";
$tcpproto = getprotobyname('tcp');
$print_request = 0;
$print_body    = 1;
$print_heads   = 0;
$follow        = 0;
$lang = '';
$refer = '';
$cookie = '';
$bv = 'lwp-request-1.38';
$dirdefault = 'dir-default';


sub base64 ($);
sub err444 ($$$);
sub monster ($$);
sub usage ($);
sub saferead ();
sub grab ($$$$$$$$);


# Header sets for browser masquerading
%headers = (
# text mode browser for Unix
# http://artax.karlin.mff.cuni.cz/~mikulas/links
# Version 0.84 does not do cookies or referer headers, so we might
# misemulate it that way.
	'links-0.84' => <<'links084Heads',
GET ${URI} HTTP/1.1
Host: ${HOST}
User-Agent: Links (0.84; Linux 2.2.5-15 i686)
${REFERER}
${COOKIE}
links084Heads

# text mode browser for Unix
# http://ei5nazha.yz.yamagata-u.ac.jp/~aito/w3m/
	'w3m-beta99' => <<'w3mb991027Heads',
GET ${URI} HTTP/1.0
User-Agent: w3m/beta-991027
Accept: text/*, image/*, audio/*, application/*
Accept-Language: ja; q=1.0, en; q=0.5
Host: ${HOST}
${REFERER}
${COOKIE}
w3mb991027Heads

# Popular alternative browser for Windows
	'Opera-3.60' => <<'Opera360Heads',
GET ${URI} HTTP/1.0
User-Agent: Mozilla/4.0 (Windows NT 4.0;US) Opera 3.60  [en]
Accept: image/gif, image/x-xbitmap, image/jpeg, image/png, */*
Host: ${HOST}
${REFERER}
${COOKIE}
Opera360Heads

# ab, the apache benchmark tool.
	'ApacheBench-1.3' => <<'AB13Heads',
GET ${URI} HTTP/1.0
User-Agent: ApacheBench/1.3
Host: ${HOST}
Accept: */*
${REFERER}
${COOKIE}
AB13Heads

# Lib WWW Perl module
	'lwp-request-1.38' => <<'LWP138Heads',
GET ${URI} HTTP/1.0
Host: ${HOST}
User-Agent: lwp-request/1.38
${REFERER}
${COOKIE}
LWP138Heads

# Popular alternative browser for Macs
	'iCab-pre1.7' => <<'iCabP17Heads',
GET ${URI} HTTP/1.0
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/xbm, image/png, */*
Accept-Language: iw
Host: ${HOST}
User-Agent: iCab/Pre1.7 (Macintosh; I; PPC)
${REFERER}
${COOKIE}
iCabP17Heads

# Popular text mode browser, predominately unix
	'Lynx-2.8.1' => <<'Lynx281Heads',
GET ${URI} HTTP/1.0
Host: ${HOST}
Accept: text/html, text/plain, application/applefile, application/x-metamail-patch, sun-deskset-message, mail-file, default, postscript-file, audio-file, x-sun-attachment, text/enriched, text/richtext, application/andrew-inset, x-be2
Accept: application/postscript, message/external-body, message/partial, application/pgp, application/pgp, video/mpeg, video/*, image/*, audio/mod, text/sgml, video/mpeg, image/jpeg, image/tiff, image/x-rgb, image/png, image/x-xbitmap, image/x-xbm
Accept: image/gif, application/postscript, video/mpeg, image/jpeg, image/x-tiff, image/x-rgb, image/x-xbm, image/gif, application/postscript, */*;q=0.01
Accept-Encoding: gzip, compress
Accept-Language: en
Negotiate: trans
User-Agent: Lynx/2.8.1rel.2 libwww-FM/2.14
${REFERER}
${COOKIE}
Lynx281Heads

# Explorer 5.0 can be installed with a compatibility mode that emulates
# (or claims to emaulate) Explorer 4.0.
	'WindowsNT-Explorer-5.0-as-4.0' => <<'WinNTExp50-40Heads',
GET ${URI} HTTP/1.0
Accept: */*
Accept-Language: en-us
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 4.01; Windows NT; compat; DigExt)
Host: ${HOST}
${REFERER}
${COOKIE}
WinNTExp50-40Heads

	'Windows98-Explorer-5.5' => <<'Win98Exp55Heads',
GET ${URI} HTTP/1.0
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*
Accept-Language: en-us
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 5.5; Windows 98)
Host: ${HOST}
${REFERER}
${COOKIE}
Win98Exp55Heads

# This is on a system with IE5.5 installed, note the reference to
# IE4.01. This one is hard to do right, since in my tests I saw
# two requests for the test file. The first came with this UA,
# the second had this instead:
# User-Agent: Mozilla/4.0 (compatible; MSIE 4.01; MSIECrawler; Windows NT)
# The crawler version had an 'Accept-Language: us-en' as well as a
# different order to the headers (Accept: User-Agent:, Accept-Language:
# Accept-Encoding, Host:).
	'WindowsNT-ActiveDesktop' => <<'WinActDeskHeads',
GET ${URI} HTTP/1.0
Accept: */*
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 4.01; Windows NT)
Host: ${HOST}
${REFERER}
${COOKIE}
WinActDeskHeads

	'WindowsNT-Netscape6' => <<'WinNTNS6Heads',
GET ${URI} HTTP/1.0
Host: ${HOST}
User-Agent: Mozilla/5.0 (Windows; U; WinNT4.0; en-US; m18) Gecko/20001108 Netscape6/6.0
Accept: */*
Accept-Language: en
Accept-Encoding: gzip,deflate,compress,identity
${REFERER}
${COOKIE}
WinNTNS6Heads

	'WindowsNT-Explorer-5.5' => <<'WinNTExp55Heads',
GET ${URI} HTTP/1.0
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*
Accept-Language: en-us
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 4.0)
Host: ${HOST}
${REFERER}
${COOKIE}
WinNTExp55Heads

	'Windows98-Explorer-4.0' => <<'Win98Exp40Heads',
GET ${URI} HTTP/1.0
Accept: */*
Accept-Language: en-us
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)
Host: ${HOST}
${REFERER}
${COOKIE}
Win98Exp40Heads

# Normal mode Windows NT IE 5.0
	'WindowsNT-Explorer-5.0' => <<'WinNTExp50Heads',
GET ${URI} HTTP/1.0
Accept: */*
Accept-Language: en-us
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 5.0; Windows NT; DigExt)
Host: ${HOST}
Pragma: no-cache
${REFERER}
${COOKIE}
WinNTExp50Heads

# IE can optional crawl pages to cache them for offline browsing.
# This is Windows NT IE 5.01 in crawl mode.
	'WindowsNT-ExplorerOffline-5.0' => <<'WinNTExpOff50Heads',
GET ${URI} HTTP/1.0
Accept: */*
Accept-Language: en-us
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 5.01; Windows NT; MSIECrawler)
Host: ${HOST}
Pragma: no-cache
${REFERER}
${COOKIE}
WinNTExpOff50Heads

	'WindowsNT-Netscape-4.6' => <<'WinNTNS46Heads',
GET ${URI} HTTP/1.0
User-Agent: Mozilla/4.6 [en] (WinNT; I)
Pragma: no-cache
Host: ${HOST}
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*
Accept-Encoding: gzip
Accept-Language: en
Accept-Charset: iso-8859-1,*,utf-8
${REFERER}
${COOKIE}
WinNTNS46Heads

	'MacPPC-Explorer-4.0' => <<'MacPPCExp40Heads',
GET ${URI} HTTP/1.0
Host: ${HOST}
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/xbm, image/x-jg, */*
Accept-Language: en
If-Modified-Since: Fri, 01 Oct 1999 00:25:43 GMT
User-Agent: Mozilla/4.0 (compatible; MSIE 4.01; Mac_PowerPC)
UA-OS: MacOS
UA-CPU: PPC
Extension: Security/Remote-Passphrase
${REFERER}
${COOKIE}
MacPPCExp40Heads

	'MacPPC-Netscape-4.0' => <<'MacPPCNS40Heads',
GET ${URI} HTTP/1.0
Proxy-Connection: Keep-Alive
User-Agent: Mozilla/4.05 (Macintosh; I; PPC, Nav)
Pragma: no-cache
Host: ${HOST}
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*
Accept-Language: en
Accept-Charset: iso-8859-1,*,utf-8
${REFERER}
${COOKIE}
MacPPCNS40Heads

	'MacPPC-Netscape-4.6' => <<'MacPPCNS46Heads',
GET ${URI} HTTP/1.0
User-Agent: Mozilla/4.6 (Macintosh; I; PPC)
Pragma: no-cache
Host: ${HOST}
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*
Accept-Encoding: gzip
Accept-Language: en
Accept-Charset: iso-8859-1,*,utf-8
${REFERER}
${COOKIE}
MacPPCNS46Heads

	'Linux-Netscape-3.0' => <<'LinNS30Heads',
GET ${URI} HTTP/1.0
User-Agent: Mozilla/3.0 (X11; I; Linux 2.2.5-15 i686)
Pragma: no-cache
Host: ${HOST}
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*
${REFERER}
${COOKIE}
LinNS30Heads

	'Linux-Netscape-4.51' => <<'LinNS451Heads',
GET ${URI} HTTP/1.0
User-Agent: Mozilla/4.51 [en] (X11; I; Linux 2.2.5-15 i686)
Pragma: no-cache
Host: ${HOST}
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*
Accept-Encoding: gzip
Accept-Language: en
Accept-Charset: iso-8859-1,*,utf-8
${REFERER}
${COOKIE}
LinNS451Heads

);

sub THEEND {
  my $signame = (shift or '(unknown)');
  die "Got SIG$signame ... exiting\n";
} # &THEEND

sub BUMP {
  my $signame = (shift or '(unknown)');
  $nosignal = 0;
} # end &BUMP 

$SIG{INT}  = 'main::THEEND';
$SIG{TERM} = 'main::THEEND';
$SIG{PIPE} = 'main::BUMP';

while(defined($ARGV[0]) and substr($ARGV[0], 0, 1) eq '-') {
    if (($ARGV[0] eq '-a') or ($ARGV[0] eq '--autoname'))  {
      $autoname = 1;
      shift;
    } elsif (($ARGV[0] eq '-B') or ($ARGV[0] eq '--no-body'))  {
      $print_body = 0;
      shift;
    } elsif (($ARGV[0] eq '-h') or ($ARGV[0] eq '--heads'))  {
      $print_heads = 1;
      shift;
    } elsif (($ARGV[0] eq '-f') or ($ARGV[0] eq '--follow'))  {
      $follow = 1;
      shift;
    } elsif (($ARGV[0] eq '-l') or ($ARGV[0] eq '--long'))  {
      $long = 1;
      shift;
    } elsif (($ARGV[0] eq '-w') or ($ARGV[0] eq '--wait'))  {
      shift;
      $waittime = shift;
      if (!defined($waittime) or $waittime !~ /^\d+$/) {
	print STDERR "$id: -w (--wait) requires an integer argument\n";
	usage(2);
      }
    } elsif (($ARGV[0] eq '-t') or ($ARGV[0] eq '--time'))  {
      eval 'use Benchmark;';
      shift;
      if ($@) { 
        warn "Can't use Benchmark module: $@\n";
      } else {
        $benchmark = shift;
	if (!defined($benchmark) or $benchmark !~ /^\d+$/) {
	  print STDERR "$id: -t (--time) requires an integer argument\n";
	  usage(2);
	}
      }
    } elsif (($ARGV[0] eq '-r') or ($ARGV[0] eq '--request'))  {
      $print_request = 1;
      shift;
    } elsif (($ARGV[0] eq '-L') or ($ARGV[0] eq '--language'))  {
      shift;
      if ($#ARGV >= 1 and substr($ARGV[0], 0, 1) ne '-') {
	$lang = shift;
      } else {
	print STDERR "$id: -L (--language) requires an argument\n";
	usage(2);
      }
    } elsif (($ARGV[0] eq '-H') or ($ARGV[0] eq '--host'))  {
      shift;
      if ($#ARGV >= 1 and substr($ARGV[0], 0, 1) ne '-') {
	$forcehost = shift;
      } else {
	print STDERR "$id: -H (--host) requires an argument\n";
	usage(2);
      }
    } elsif (($ARGV[0] eq '-u') or ($ARGV[0] eq '--user'))  {
      shift;
      if ($#ARGV >= 1 and substr($ARGV[0], 0, 1) ne '-') {
	$user = &base64(shift);
      } else {
	print STDERR "$id: -u (--user) requires an argument\n";
	usage(2);
      }
    } elsif (($ARGV[0] eq '-p') or ($ARGV[0] eq '--post'))  {
      shift;
      if ($#ARGV >= 1 and substr($ARGV[0], 0, 1) ne '-') {
	$post = shift;
      } else {
	print STDERR "$id: -p (--post) requires an argument\n";
	usage(2);
      }
    } elsif (($ARGV[0] eq '-R') or ($ARGV[0] eq '--refer'))  {
      shift;
      if ($#ARGV >= 1 and substr($ARGV[0], 0, 1) ne '-') {
	$refer = shift;
      } else {
	print STDERR "$id: -r (--refer) requires an argument\n";
	usage(2);
      }
    } elsif (($ARGV[0] eq '-c') or ($ARGV[0] eq '--cookie'))  {
      shift;
      if ($#ARGV >= 1 and substr($ARGV[0], 0, 1) ne '-') {
	$cookie = shift;
      } else {
	print STDERR "$id: -c (--cookie) requires an argument\n";
	usage(2);
      }
    } elsif (($ARGV[0] eq '-b') or ($ARGV[0] eq '--browser'))  {
      shift;
      if ($#ARGV >= 1 and substr($ARGV[0], 0, 1) ne '-') {
	$ARGV[0] =~ /([\w.\d-]+)/; shift;
	$bv = $1;
	if (!defined($headers{$bv})) {
	  print STDERR "$id: $bv is not a recognized browser\n";
	  usage(2);
	}
      } else {
	print STDERR "$id: -b (--browser) requires an argument\n";
	usage(2);
      }
  } elsif ($ARGV[0] eq '--version') {
    print "$0 version $VERSION $LONG_VERSION_INFO\n";
    exit(0);
  } elsif ($ARGV[0] eq '--emulations') {
    &usage_emulations();
    exit(0);
  } elsif ($ARGV[0] eq '--languages') {
    &usage_languages();
    exit(0);
  } elsif ($ARGV[0] eq '--help') {
    &usage(0);
  } else {
    print STDERR "$0: $ARGV[0] not a recognized option\n";
    &usage(2);
  }
}


if (!defined($ARGV[0])) {
  print STDERR "No URL found\n";
  usage(2);
}

if ($benchmark) {
  timethis($benchmark, 
    sub {
      for $url (@ARGV) {
	&do_one($url, 1);
      }
    }
  );
} else {
  my $sleep;

  # Normal loop through them.
  while(defined($url = shift)) {
    sleep $sleep if $sleep;
    &do_one($url, 0);
    $sleep = $waittime;
  }

}
exit(0);

#####################################################
# Process one URL from the command line. If $timing is set,
# don't optimize away the actual request.
sub do_one ($$) {
  my $url = shift;
  my $timing = shift;
  my $nport = 80;
  my $host;
  my $connecthost;
  my $proto;
  my $lpart = '/';
  my $header = $headers{$bv} . $EOL;
  my $ans;	# holds response from web server
  my $newreq;

  # Simple-mindedly parse the request

  if ($url !~ m%(https?):/+([^/]+)(/.+)?%) {
    warn("Can't get host for $url; skipping\n");
    return undef;
  } else {
    $proto = $1;
    $host = $2;
    $lpart = $3 if defined($3);
  }

  if ($autoname) {
    my $out = $lpart;

    $out =~ s:.*/::;
    if (length($out) < 1) {
      $out = $dirdefault;
    }

    if (open(STDOUT,">$out")) {
      print STDERR "Sending output going to $out\n";
    } else {
      warn "Can't open $out for output.\n";
    }
  }

  if (defined($forcehost)) {
    $connecthost = $forcehost;
  } else {
    $connecthost = $host;
  }

  # Do referer headers, etc.
  if ($long) { 
    $header =~ s#\${URI}#$proto://${host}$lpart#g;
  } else {
    $header =~ s/\${URI}/$lpart/g;
  }
  $header =~ s/\${HOST}/$host/g;
  $header =~ s/\${REFERER}/Referer: $refer/g;
  $header =~ s/\${COOKIE}/Cookie: $cookie/g;

  if ($lang) {
    $header =~ s/Accept-Language:[^\cm\cj]*\cm?\cj/Accept-Language: $lang$EOL/i;
  }

  if ($user) {
    $header =~ s/\cm?\cj\cm?\cj/${EOL}Authorization: Basic $user$EOL/;
  }

  if ($post) {
    my $size = length($post);
    # may someday support multipart/form-data, too
    my $formtype = 'application/x-www-form-urlencoded';

    $header =~ s/^GET/POST/;
    $header =~ s/\cm?\cj\cm?\cj/${EOL}Content-Type: $formtype${EOL}Content-Length: $size$EOL$EOL/;
    $header .= $post;
  }

  $header =~ s/\cm?\cj/$EOL/g;

  # Grab first line for &grab
  $header =~ s/^([^\cm\cj]+$EOL)//;
  $newreq = $1;

  # Delete empty headers
  $header =~ s/\cM?\cJ([^\s:]+):\s(?=\cM?\cJ)//g;

  # Log the request
  print "$newreq$header" if $print_request;
  print "\n"             if($print_request and $post);

  if (!($print_heads or $print_body) and !$timing) {
    return "$newreq$header";
  }

  # Strip :port off of host before the grab. (It needs to be left in above
  # for the Host: header to work right.)
  if ($connecthost =~ s/:(\d+)//) {
    $nport = $1;
  }

  # Fetch the page
  $ans = &grab($connecthost, $nport, 
	       \$newreq, \$header, 
	       $print_heads, $print_body, $timing, $follow);
} # end &do_one  


#####################################################
# Grab an html page. Needs a remote hostname, a port number
# a first line request (eg "GET / HTTP/1.0"), and the remainder
# of the request (empty string if HTTP/0.9).
sub grab ($$$$$$$$) {
  my ($remote, $port, $request, $heads, $printhead, $printbody, $no_optimize,
      $doredir) = @_;
  my ($iaddr, $paddr, $line);
  my $out = '';
  my $len;
  my $rc;

  if (!($iaddr = inet_aton($remote))) { 
    return &err444("no host: $remote", $printhead, $printbody);
  }

  $paddr   = sockaddr_in($port, $iaddr);

  print 'Peer is ' .  inet_ntoa($iaddr) . ":$port\n" if $debug;

  if (!socket(SOCK, PF_INET, SOCK_STREAM, $tcpproto)) {
    return &err444("socket: $!", $printhead, $printbody);
  }
  if (!connect(SOCK, $paddr)) {
    return &err444("connect: $!", $printhead, $printbody);
  }

  $len = length($$request);
  $rc = syswrite(SOCK, $$request, $len);

  if ($rc != $len) {
    warn("request write to $remote was short ($rc != $len)\n");

  } else {
    $len = length($$heads);
    $rc = syswrite(SOCK, $$heads, $len);

    warn("heads write to $remote was short ($rc != $len)\n")
    	if ($rc != length($$heads));
  }

  $nosignal = 1;

  while ($line = &saferead() and $nosignal) {
    $out .= $line;
    last if ($line =~ /^\015?\012?$/);
  }

  print $out if $printhead;

  if (!$printbody and !$no_optimize) {
    close (SOCK)            || die "close: $!";
    if ($doredir) {
      if ($out =~ /(?:\015?\012|015\012?)Location:[ \t]*([^\015\012]+)/i) {
        my $newurl = $1;
	print STDERR "Following redirection to $newurl\n";
	$out = &do_one($newurl, 0);
      }
    }
    return $out;
  }

  if ($out =~ /\nContent-Length:\s+(\d+)/) {
    # OLD store every way : read(SOCK,$out,$1,length($out));
    my $tograb = $1;
    my $chunk  = 512;	# not too large, since it is off the network
    my $buf;
    my $rc;

    while($tograb >= $chunk) {
      $buf = '';
      $rc = read(SOCK,$buf,$chunk,0);
      print $buf if $printbody;
      if ($rc != $chunk) {
        warn "Return from $remote read was short (got $rc of $chunk)\n";
	return $out;
      }

      $tograb -= $chunk;
    }

    if ($tograb > 0) {
      $buf = '';
      $rc = read(SOCK,$buf,$tograb,0);
      print $buf if $printbody;
      if ($rc != $tograb) {
        warn "Return from $remote read was short (got $rc of $tograb)\n";
	return $out;
      }
    }

  } else {

    $nosignal = 1;
    # Back to line by line mode.
    while (defined($line = <SOCK>) and $nosignal) {
      # OLD store every way : $out .= $line;
      print $line if $printbody;
    }
  }

  close (SOCK)            || die "close: $!";

  if ($doredir) {
    if ($out =~ /(?:\015?\012|015\012?)Location:[ \t]*([^\015\012]+)/i) {
      my $newurl = $1;
      print STDERR "Following redirection to $newurl\n";
      $out = &do_one($newurl, 0);
    }
  }
  return $out;
} # end &grab

#####################################################
# Attempt to read a line safely from SOCK filehandle.
sub saferead () {
  my $line;
  eval {
  	local$SIG{ALRM} = sub { die 'timeout!' };
	alarm 15;
	$line = <SOCK>;
	alarm 0;
       };
  if ($@ and $@ !~ /timeout!/) {warn("during socket read: $@\n")}
  return $line;
} # end &saferead 

#####################################################
# Print a usage message. Exits with the number passed in.
sub usage ($) {
  my $exit = shift;

  print <<"EndUsage";
$0 usage:
  bget [options] URL [URL...]

Basic tool to make HTTP GET requests and monitor the results.
Unlike LWP GET, it does not require special Perl modules, and
by virtue of being cruder makes HTTP headers easier to spy on.
Only URLs of the forms 

     http://hostname/[localpart]
     http://hostname:port/[localpart]

are supported.

Options:
  	-a --autoname		save output automatically based on URI
  	-B --no-body		don't print the body of the response
	-f --follow		follow redirects
	-h --heads		print the response headers
	-l --long		use long address on GET line (using the
				full http://... should work in HTTP/1.1)
	-r --request		print the request headers
	-H --host     HOST[:P] 	connect to HOST for request (useful for
				testing virtual hosts before a DNS change)
	-L --language LANG	use LANG for Accept-Language:
	-R --refer    VALUE	set the referer header with VALUE
	-c --cookie   VALUE	set the cookie header with VALUE
	-b --browser  NAME	what browser to emulate
	-u --user     USER:PW	basic authentification as USER:PW
	-p --post     STRING	use STRING as a post form contents (forms of
				type application/x-www-form-urlencoded only)
	-t --time     N		use Benchmark module to time making
				request(s) N times
	-w --wait     N		wait N seconds between fetching each URL

	--help                  show this help and exit
	--version               print version and exit
	--emulations            print list of available emulations
	--languages             print a sample of language codes

Note: If -H (--host) is used with multiple URLs, all connections are
      made to the specified HOST (and port) even if different hosts
      are used in the URLs. This can be used to fetch files through
      a HTTP proxy if -l (--long) is also used.

      With -L (--langauge) the Accept-Language: header will not be
      added if the browser has not been observed to use it.
EndUsage

  exit($exit);
} # end &usage 

sub usage_languages() {
  print <<'LanguageRef';
In HTTP standard languages have a two letter code, with an optional
two letter country code qualifier. English is 'en', but American
English is 'en-us', Irish English is 'en-ie', Australian English is
'en-au'.

Some other lanuages:
  af	Afrikaans
  sq	Albanian
  eu	Basque
  bg	Bulgarian
  be	Byelorussian
  ca	Catalan
  zh	Chinese
  zh-cn	Chinese/China
  zh-tw	Chinese/Taiwan
  hr	Croatian
  cs	Czech
  da	Danish
  nl	Dutch
  nl-be	Dutch/Belgium
  fo	Faeroese
  fi	Finnish
  fr	French
  fr-be	French/Belgium
  fr-ca	French/Canada
  fr-fr	French/France
  fr-ch	French/Switzerland
  gl	Galician
  de	German
  de-at	German/Austria
  de-de	German/Germany
  de-ch	German/Switzerland
  el	Greek
  hu	Hungarian
  is	Icelandic
  id	Indonesian
  ga	Irish
  it	Italian
  ja	Japanese
  ko	Korean
  mk	Macedonian
  no	Norwegian
  pl	Polish
  pt	Portuguese
  pt-br	Portuguese/Brazil
  ro	Romanian
  ru	Russian
  gd	Scots Gaelic
  sr	Serbian
  sk	Slovak
  sl	Slovenian
  es	Spanish
  es-ar	Spanish/Argentina
  es-co	Spanish/Colombia
  ex-mx	Spanish/Mexico
  es-es	Spanish/Spain
  sv	Swedish
  tr	Turkish
  uk	Ukrainian

This list is from the default set of lanuages in Netscape 4.5.
IE has a different set, including more country variations.

LanguageRef
}

sub usage_emulations() {
  my $key;
  my @keys = sort {$a cmp $b} keys %headers;
  my $k = scalar @keys;

  print "The following $k browsers are recognized for header emulation:\n";
  foreach $key (@keys) {
    print "\t$key\n" if length($headers{$key});
  }

}

#####################################################
# For managing cookies, a monster.
sub monster ($$) {
  my $host = shift;
  my $reqref = shift;

  return unless defined($$reqref) and length($$reqref);
  if ($host =~ /\.doubleclick\./) {
    $$reqref =~ s/\cjCookie:[^\cm\cj]*/\cjX-Monster: doubleclick cookie eaten/gi;
  } elsif ($host =~ /^(ads|adforce|adserv[er]*)\./i) {
    $$reqref =~ s/\cjCookie:[^\cm\cj]*/\cjX-Monster: $1.* host cookie eaten/gi;
  }

} # end &monster 

sub err444 ($$$) {
  my $why = shift;
  my ($phead, $pbody) = @_;

  my $return;
($return = <<"444ErrorHead") =~ s/\cj/\cm\cj/g;
HTTP/1.0 444 Not Found
X-Declined: $why
Content-Type: text/html
Content-Length: 28

444ErrorHead

  my $body;
$body = <<"444ErrorBody";
<html><head><title>Error 444</title></head><body>
<h1>Error 444 Not Found</h1>
<p>$why</p>
</body></html>
444ErrorBody

  print $return if $phead;
  print $body   if $pbody;

  return($return);
} # end &err444

# This code stolen from MIME::Base64's perl-only backup. The XS
# version is much faster, but I don't want to assume it is installed.
sub base64 ($) {
    my $res = "";
    my $eol = "\n";
    pos($_[0]) = 0;                          # ensure start at the beginning
    while ($_[0] =~ /(.{1,45})/gs) {
        $res .= substr(pack('u', $1), 1);
        chop($res);
    }
    $res =~ tr|` -_|AA-Za-z0-9+/|;               # `# help emacs
    # fix padding at the end
    my $padding = (3 - length($_[0]) % 3) % 3;
    $res =~ s/.{$padding}$/'=' x $padding/e if $padding;
    # break encoded string into lines of no more than 76 characters each
    if (length $eol) {
        $res =~ s/(.{1,76})/$1$eol/g;
    }
    $res;
} # end &base64 

__END__


