use Env qw(XDSI);
require xdsi;

# This script performs Rad-69 retrieve from an Imaging Document Source.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension simulator-name ids_name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  extension          Specifies test data set (a, b, c, ...) \n" .
    "  ids_name           Name of the IDS(for a .ini file)\n"
 if ($arg_count != 3);


my $label     =  $ARGV[0];
my $extension =  $ARGV[1];
my $ids_name  =  $ARGV[2];
my $pid_dept  = "IDS-DEPT002-$extension";
my $pid_ad    = "IDS-AD002-$extension";
my $test_name = "ids-rad69-multi";


print "Label:     $label\n";
print "Extension: $extension\n";
print "Local ID:  $pid_dept\n";
print "AD ID:     $pid_ad\n";
print "IDS Name:  $ids_name\n";

xdsi::ini_exists($ids_name);

xdsi::rad69_kos($pid_dept, $pid_ad, $ids_name,  $extension, $label, $test_name, "options not used");


