use Env qw(XDSI);
require xdsi;

# Validation script for iig-1021 test.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label iig_name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  session            Testing session (AKA user name)\n" .
    "  iig_name           Name of the IIG (for a .ini file)\n"
 if ($arg_count != 3);

my $label     =  $ARGV[0];
my $session   =  $ARGV[1];
my $iig_name  =  $ARGV[2];

my $pid_dept = "IIG-DEPT1011";
my $test_name  = "iig-1021";

print "Label:     $label\n";
print "Session:   $session\n";
print "Local ID:  $pid_dept\n";
print "IIG Name:  $iig_name\n";

xdsi::ini_exists($iig_name);

xdsi::validate_iig_xc_retrieve($iig_name,  $label, $session, $test_name);

