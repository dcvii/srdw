# !/usr/bin/perl
## mbowen - 20020530.1100 last update - mbowen@mdcbowen.org
##        - for secmod 13 dimensional mess


# init
$max = 30000;
$maxval = 5;
$topmax = 1;
system ("cls");
@curveType = ("linear","exponential","asmyptotic","flat");


$dpath = "/03fs03/vendors/essbase650/batch/mdev/data/";
$spath = "/03fs03/vendors/essbase650/batch/mdev/script/";
$lpath = "/03fs03/vendors/essbase650/batch/mdev/log/";



# input file
# dimx:dimname:top:curve:filename:permflag
# new 20030220.1500 mbowen doperm array.


#	time will always be the d1+n dimension
#	measures will always be the d2+n dimension
#	scenario will always be the d3+n dimension
#
#	where 'n' is the number of sparse dims input?


# open and parse inputfile
$n = $ndims = 0;
$fspec = $spath."inx.dat";
open (INFILE, $fspec) || die "input file broken or missing\n";
while (<INFILE>) {
	chop;
	(undef,$dimname[$n],$top[$n],$curve[$n],$doperm[$n],$filespec[$n]) = split(/:/, $_, 6);
	$n++;

}
close INFILE;
$ndims = $n;
print "ndims: $n.\n";

if ($ndims>7 or ($ndims<3)) {die "bad ndims.\n";}

# read in dim files

$topmax = 1;
for ($n=0;$n<$ndims;$n++) {
	$fspec = $dpath.$filespec[$n];
	open (DIM, $fspec) || die "can't open dimfile $filespec[$n]\n";

	$i = 0;
	while (<DIM>) {
		chop;
		$i++;
		$dim[$n][$i-1] = $_;
	}
	close DIM;
	$dsize[$n] = $i;

	# other variables
	$topmax *= $top[$n];
	print "---------------\n";
	if (not $doperm[$n]) {
		print "rolling style\n";
		$top[$n] = $dsize[$n];
	}
	print "dim: $dimname[$n]\ntop: $top[$n]\nsize: $dsize[$n]\ncurve: $curveType[$curve[$n]]\n";

}

print "topmax: $topmax\n";

$fspec = $dpath."dates.txt";
# now pull dates from standard 36 month date file
open (DATES, $fspec) || die "can't open dates\n";

$i = 0;
while (<DATES>) {
	chop;
	$i++;
	$dates[$i-1] = $_;
}
close DATES;
print "\n\n\got dates.\n";



# now pick labels for ranking measure
print "\nselecting top labels...";

for ($n=0;$n<$ndims;$n++){

	for ($i=0;$i<$top[$n];$i++){
		if ($doperm[$n]) {
			$topdim[$n][$i] = $dim[$n][int(rand $dsize[$n])];
		} else {
			$topdim[$n][$i] = $dim[$n][$i];
		}
	}
}

print "done\n";


# assign dim factors according to the curve formulas

print "\n\n..calculating dim factors..\n";

$mx = $mn = 1;
for ($n=0;$n<$ndims;$n++) {
	if ($curve[$n]==0) {
		@a = &linCurve($top[$n]);
	} elsif ($curve[$n]==1)	{
		@a = &expCurve($top[$n]);
	} elsif ($curve[$n]==2) {
		@a = &asyCurve($top[$n]);
	} else {
		@a = &fltCurve($top[$n]);
	}

	# how can we assign these arrays faster?

	for ($i=0;$i<$top[$n];$i++) {
		$df[$n][$i] = $a[$i];
	}


#	$mn *= $df[$n][0];
	$mx *= $df[$n][$top[$n]-1];
	# &PrintArray($top[$n],@dimfactor[$n]);
}

print "\n\ndimfactors calculated.	\n";
print "mx: $mx \n";

$adj = 10000/$mx;





print "maxfactor: $mx\nminfactor: $min\n";
print "max of factors: $mx adjusted to $maxval by $adj.\n";


# now get ready for output
# top label permutations
print "\n\n..writing top label permutations..";
$fspec = "> $dpath"."tp.txt";
open (OUT, $fspec) || die "cannot create output.\n";
$i = $j = $k = $l = $done = 0;


if ($ndims==3) {
	for ($i=0; $i<$top[0]; $i++) {
		for ($j=0; $j<$top[1]; $j++) {
			for ($k=0; $k<$top[2]; $k++) {
				$num = int($df[0][$i]*$df[1][$j]*$df[2][$k]*$adj)+1;
				$dat = $dates[int(rand 36)+1];
				$record = "$topdim[0][$i]\t$topdim[1][$j]\t$topdim[2][$k]\t$dat\t$num\n";
				print OUT $record;
			}
		}
	}
	close OUT;
	print "done.\n";
}

if ($ndims==4) {
	for ($i=0; $i<$top[0]; $i++) {
		for ($j=0; $j<$top[1]; $j++) {
			for ($k=0; $k<$top[2]; $k++) {
				for ($l=0;$l<$top[3];$l++) {
					$num = int($df[0][$i]*$df[1][$j]*$df[2][$k]*$df[3][$l]*$adj)+1;
					$dat = $dates[int(rand 36)+1];
					$record = "$topdim[0][$i]\t$topdim[1][$j]\t$topdim[2][$k]\t$topdim[3][$l]\t$dat\t$num\n";
					print OUT $record;
				}
			}
		}
	}
	close OUT;
	print "done.\n";

}


if ($ndims==5) {
	for ($i=0; $i<$top[0]; $i++) {
		for ($j=0; $j<$top[1]; $j++) {
			for ($k=0; $k<$top[2]; $k++) {
				for ($l=0;$l<$top[3];$l++) {
					for ($ii=0;$ii<$top[4];$ii++) {
						$num = int($df[0][$i]*$df[1][$j]*$df[2][$k]*$df[3][$l]*$df[4][$ii]*$adj)+1;
						$dat = $dates[int(rand 36)+1];
						$record = "$topdim[0][$i]\t$topdim[1][$j]\t$topdim[2][$k]\t";
						$record .= "$topdim[3][$l]\t$topdim[4][$ii]\t$dat\t$num\n";
						print OUT $record;
					}
				}
			}
		}
	}
	close OUT;
	print "done.\n";

}

if ($ndims==6) {
	for ($i=0; $i<$top[0]; $i++) {
		for ($j=0; $j<$top[1]; $j++) {
			for ($k=0; $k<$top[2]; $k++) {
				for ($l=0;$l<$top[3];$l++) {
					for ($ii=0;$ii<$top[4];$ii++) {
						for ($jj=0; $jj<$top[5];$jj++) {
							$num = int($df[0][$i]*$df[1][$j]*$df[2][$k]*
							  $df[3][$l]*$df[4][$ii]*$df[5][$jj]*$adj)+1;
							$dat = $dates[int(rand 36)+1];
							$record = "$topdim[0][$i]\t$topdim[1][$j]\t$topdim[2][$k]\t";
							$record .= "$topdim[3][$l]\t$topdim[4][$ii]\t$topdim[5][$jj]\t$dat\t$num\n";
							print OUT $record;
						}
					}
				}
			}
		}
	}
	close OUT;
	print "done.\n";

}

if ($ndims==7) {
	for ($i=0; $i<$top[0]; $i++) {
		for ($j=0; $j<$top[1]; $j++) {
			for ($k=0; $k<$top[2]; $k++) {
				for ($l=0;$l<$top[3];$l++) {
					for ($ii=0;$ii<$top[4];$ii++) {
						for ($jj=0; $jj<$top[5];$jj++) {
							for ($kk=0; $kk<$top[6];$kk++) {
								$num = int($df[0][$i]*$df[1][$j]*$df[2][$k]*
								  $df[3][$l]*$df[4][$ii]*$df[5][$jj]*$df[6][$kk]*$adj)+1;
								$dat = $dates[int(rand 36)+1];
								$record =  "$topdim[0][$i]\t$topdim[1][$j]\t$topdim[2][$k]\t";
								$record .= "$topdim[3][$l]\t$topdim[4][$ii]\t$topdim[5][$jj]\t";
								$record .= "$topdim[6][$kk]\t$dat\t$num\n";
								print OUT $record;
							}
						}
					}
				}
			}
		}
	}
	close OUT;
	print "done.\n";

}
# bottom label permutations (for n-dimensions)
#   note that there can be duplicates here which will skew the top labels a bit out of bounds
#   this is more or less likely to occur depending on the ratio of top1/dim1size
$fspec = "> $dpath"."bp.txt";
print "\n\n..writing bottom label permutations..";
open (OUT, $fspec) || die "cannot create output.\n";


for ($j=$topmax; $j<$max; $j++) {
	$record = "";
	for ($n=0;$n<$ndims;$n++) {
		$dIndex[$n] = int(rand $dsize[$n]);
		$record .= "$dim[$n][$dIndex[$n]]\t";
	}
	$num = int(rand $maxval);
	$dat = $dates[int(rand 36)+1];
	$record .= "$dat\t$num\n";
	print OUT $record;
}


sub PrintArray {
	local $size = shift;
	local @a = @_;
	for ($j=0; $j<$size; $j++) {

		$record = "$a[$j]\n";
		print $record;

	}

}


sub linCurve {

	local $size = $_[0];
	local @a;
	for ($i=0;$i<$size;$i++){
		$a[$i] = $i+1;
	}

	return @a;

}

sub expCurve {

	local $size = $_[0];
	local @a;
	for ($i=0;$i<$size;$i++){
		$a[$i] = ($i+1)**2;
	}

	return @a;

}

sub asyCurve {

	local $size = $_[0];
	local @a;
	$b=$size/2;
	for ($i=0;$i<$size;$i++){
		$a[$i] = 1+(log($i+1))**2;
	}

	return @a;

}

sub fltCurve {

	local $size = $_[0];
	local @a;
	for ($i=0;$i<$size;$i++){
		$a[$i] = 1;
	}

	return @a;

}


## -- comment section


#  mbowen 20030220.1500
#  doperm array is added to change the labels in a particular dimension so that they don't permute
#  rather they just tickoff. in this case, there should be a large number in the second column.
#  although it's not checked, the 'rolling style' dimension which doesn't permute, should be on the
#  farthest nested loop. in other words at the bottom of the inx.dat file. it will automatically
#  roll through all of the labels, overriding the 'top' variable and using the full dimension size.