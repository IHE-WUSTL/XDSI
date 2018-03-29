use Env qw(XDSI);
require xdsi;

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Usage: simulator-name ids-single-image-02.pl LOCAL_ID AFFINITY-DOMAIN_D \n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xdsi01__rep-reg\n" .
    "  LOCAL_ID           Patient identifier for departmental (local) work\n" .
    "  AFFINITY-DOMAIN_ID Patient identifier for Affinity Domain\n"
 if ($arg_count == 0);

print "Simulator: $ARGV[0]\n";
print "Local ID:  $ARGV[1]\n";
print "AD ID   :  $ARGV[2]\n";

xdsi::validate_rad68_dry_run(@ARGV);


