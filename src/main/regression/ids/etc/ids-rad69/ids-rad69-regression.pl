use Env qw(XDSI);
require xdsi;

xdsi::check_environment();

sub execute {
 my $jar = shift(@_);
 my $x   = shift(@_);
 while (scalar(@_) > 0) {
  $x .= " " . shift(@_);
 }

 print "\n$x\n";
# print `$x`;

}

# Main starts here

  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC ";
  my $url = "http://www.xyz.com";
  my $repid = "1.2.3";

  execute($jar, $x, "KOS" );

  execute($jar, $x, "KOS", "/tmp/rad69/kos", $url, $repid, "xfersyntax.txt", "kos.dcm");

  execute($jar, $x, "SINGLE", "/tmp/rad69/single", $url, $repid, "xfersyntax.txt",
	"1.3.6.1.4.1.21367.201599.1.201602281031047:1.3.6.1.4.1.21367.201599.2.201602281031047.21:1.3.6.1.4.1.21367.201599.3.201602281031047.35");

  execute($jar, $x, "MULTI", "/tmp/rad69/multi", $url, $repid, "xfersyntax.txt", "uids.txt");

  execute($jar, $x, "VERBATIM", "/tmp/rad69/verbatin", $url, $repid, "xfersyntax.txt", "verbatim.xml");
