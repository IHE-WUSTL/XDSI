use Env qw(XDSI);
require xdsi;

# This script performs C-Move operations at different levels in
# the DICOM information model.

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
my $test_name = "ids-multimodality-b";


print "Label:     $label\n";
print "Extension: $extension\n";
print "Local ID:  $pid_dept\n";
print "AD ID:     $pid_ad\n";
print "CMove:     $ids_name\n";
print "Simulator: $simulator\n";

xdsi::ini_exists($ids_name  );
xdsi::rad16_sequence($pid_dept, $pid_ad, $simulator, $ids_name,  $extension, $label, $test_name, "STUDY:SERIES:INSTANCE");
xdsi::rad55_multi   ($pid_dept, $pid_ad, $simulator, $ids_name,  $extension, $label, $test_name, "STUDY:SERIES:INSTANCE");
xdsi::rad69_kos     ($pid_dept, $pid_ad,             $ids_name,  $extension, $label, $test_name, "options not used");



