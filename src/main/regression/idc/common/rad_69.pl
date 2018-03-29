#!/usr/bin/perl
use Env qw(XDSI);

print "Regression rad_69\n";

my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
	"SINGLE " .
	"/tmp/xxx " .
	"http://ids-simulator.wustl.edu:9280/xdstools2/sim/xdsi01__img-doc-src-a/ids/ret.ids " .
	"1.1.4567332.10.99 " .
	"\"\" " .
	"1.3.6.1.4.1.21367.201599.1.201602281031046:1.3.6.1.4.1.21367.201599.2.201602281031046:1.3.6.1.4.1.21367.201599.3.201602281031046.1";

print "$x\n";
print `$x`;
