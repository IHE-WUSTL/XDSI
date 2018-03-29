use Env qw(XDSI);
require xdsi;

# Validation script for ids-rad55-single test.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension simulator-name ids_name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  extension          Specifies test data set (a, b, c, ...) \n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xdsi01__rep-reg\n" .
    "  ids_name           Name of the C-Move SCP (for a .ini file)\n"
 if ($arg_count != 4);

my $label     =  $ARGV[0];
my $extension =  $ARGV[1];
my $simulator =  $ARGV[2];
my $cmove_name = $ARGV[3];
my $pid_dept  = "IDS-DEPT001-$extension";
my $pid_ad    = "IDS-AD001-$extension";
my $test_name = "ids-rad55-single";


print "Label:     $label\n";
print "Extension: $extension\n";
print "Local ID:  $pid_dept\n";
print "AD ID:     $pid_ad\n";
print "CMove:     $cmove_name\n";
print "Simulator: $simulator\n";

xdsi::validate_rad55_multi($pid_dept, $pid_ad, $simulator, $cmove_name,  $extension, $label, $test_name);


