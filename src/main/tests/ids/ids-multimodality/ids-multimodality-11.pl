use Env qw(XDSI);
require xdsi;

# Performs all validation for ids-multimodality test

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension simulator-name ids_name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  extension          Specifies test data set (a, b, c, ...) \n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xxx__rep-reg\n" .
    "  ids_name           Name of the C-Move SCP (for a .ini file)\n"
 if ($arg_count != 4);

my $label     =  $ARGV[0];
my $extension =  $ARGV[1];
my $simulator =  $ARGV[2];
my $ids_name   = $ARGV[3];

my $pid_dept  = "IDS-DEPT027-$extension";
my $pid_ad    = "IDS-AD027-$extension";
my $test_name = "ids-multimodality-a";

print "Label    : $label\n";
print "Extension: $extension\n";
print "Simulator: $simulator\n";
print "PID Dept:  $pid_dept\n";
print "PID AD:    $pid_ad\n";

xdsi::ini_exists($ids_name);

xdsi::validate_rad68_v2($simulator, $pid_dept, $pid_ad, $label, $extension, $test_name);

$test_name = "ids-multimodality-b";
xdsi::validate_ids_all_transactions($pid_dept, $pid_ad, $simulator, $ids_name,  $extension, $label, $test_name, "STUDY:SERIES:INSTANCE");


