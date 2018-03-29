use Env qw(XDSI);
require xdsi;

# This script performs C-Move operations at different levels in
# the DICOM information model.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension simulator-name ids_name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  extension          Specifies test data set (a, b, c, ...) \n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xdsi01__rep-reg\n" .
    "  ids_name           Name of the C-Move SCP (for a .ini file)\n"
 if ($arg_count != 4);


#die "Usage: ids-rad16-single-10.pl LOCAL_ID AFFINITY-DOMAIN_ID C-Move_SCP_Name [simulator-name] \n" .
#    "  LOCAL_ID           Patient identifier for departmental (local) work\n" .
#    "  AFFINITY-DOMAIN_ID Patient identifier for Affinity Domain\n" .
#    "  C-Move_SCP_Name    Name of the C-Move SCP (for a .ini file)\n" .
#    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xdsi01__rep-reg\n" 
# if ($arg_count == 0);

my $label     =  $ARGV[0];
my $extension =  $ARGV[1];
my $simulator =  $ARGV[2];
my $cmove_name = $ARGV[3];
my $pid_dept  = "IDS-DEPT001-$extension";
my $pid_ad    = "IDS-AD001-$extension";
my $test_name = "ids-rad16-single";


print "Label:     $label\n";
print "Extension: $extension\n";
print "Local ID:  $pid_dept\n";
print "AD ID:     $pid_ad\n";
print "CMove:     $cmove_name\n";
print "Simulator: $simulator\n";

xdsi::ini_exists($cmove_name);
#xdsi::rad16_sequence($ARGV[0], $ARGV[1], $simulator, $cmove_name, "STUDY:SERIES:INSTANCE");
xdsi::rad16_sequence($pid_dept, $pid_ad, $simulator, $cmove_name,  $extension, $label, $test_name, "STUDY:SERIES:INSTANCE");

