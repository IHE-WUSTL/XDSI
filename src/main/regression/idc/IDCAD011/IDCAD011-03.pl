use Env qw(XDSI);
require xdsi;
# This script performs a series of RAD55/WADO retrieve operations based on
# a DICOM KOS object. All images referenced in the KOS object are
# retrieved using the RAD55 transaction.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Usage: ids-rad55-single-03.pl LOCAL_ID AFFINITY-DOMAIN_ID WADO-URL [simulator-name] \n" .
    "  LOCAL_ID           Patient identifier for departmental (local) work\n" .
    "  AFFINITY-DOMAIN_ID Patient identifier for Affinity Domain\n" .
    "  WADO-URL		  URL of the WADO service\n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xdsi01__rep-reg\n" 
 if ($arg_count == 0);

my $wado_url  = $ARGV[2];
my $simulator = "xdsi01__rep-reg";
$simulator    = $ARGV[3] if (scalar(@ARGV) > 3);

print "Local ID:  $ARGV[0]\n";
print "AD ID:     $ARGV[1]\n";
print "WADO URL:  $wado_url\n";
print "Simulator: $simulator\n";

xdsi::rad55_baseline_idc($ARGV[0], $ARGV[1], $simulator, $wado_url, "STUDY:SERIES:INSTANCE");


