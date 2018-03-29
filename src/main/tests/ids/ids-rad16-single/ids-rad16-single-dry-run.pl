use Env qw(XDSI);
require xdsi;

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension simulator-name \n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  extension          Specifies test data set (a, b, c, ...) \n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xdsi01__rep-reg\n" 
 if ($arg_count == 0);

my $label     =  $ARGV[0];
my $extension =  $ARGV[1];
my $simulator =  $ARGV[2];
my $pid_dept  = "IDS-DEPT001-$extension";
my $pid_ad    = "IDS-AD001-$extension";
my $test_name = "ids-rad16-single";

print "Label    : $label\n";
print "Extension: $extension\n";
print "Simulator: $simulator\n";
print "PID Dept:  $pid_dept\n";
print "PID AD:    $pid_ad\n";


xdsi::validate_rad68_dry_run_v2($simulator, $pid_dept, $pid_ad, $label, $extension, $test_name);


