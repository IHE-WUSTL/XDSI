use Env qw(XDSI);
require xdsi;

# Validation script for rig-2004 test.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label session iig_name\n" .
    "  label              Label for the Responding Imaging Gateway (no spaces)\n" .
    "  session            Testing session (AKA user name)\n" .
    "  rig_name           Name of the RIG (for a .ini file)\n"
 if ($arg_count != 3);

my $label     =  $ARGV[0];
my $session   =  $ARGV[1];
my $rig_name  =  $ARGV[2];

my $test_name  = "rig-2004";

print "Label:     $label\n";
print "Session:   $session\n";
print "RIG Name:  $rig_name\n";

xdsi::ini_exists($rig_name);

xdsi::validate_rig_xc_retrieve($rig_name,  $label, $session, $test_name);

