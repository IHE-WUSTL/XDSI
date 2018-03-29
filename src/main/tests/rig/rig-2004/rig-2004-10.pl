use Env qw(XDSI);
require xdsi;

# This script performs Rad-75 retrieve from a Responding Imaging Gateway.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label rig_name \n" .
    "  label              Label for the RIG under test (no spaces)\n" .
    "  rig_name           Name of the RIG (for a .ini file)\n"
 if ($arg_count != 2);

my $label      =  $ARGV[0];
my $rig_name   =  $ARGV[1];
my $test_name  = "rig-2004";
my $uid_path   = "../tests/rig/rig-2004/rig-2004.txt";
my $xfer_syntax_path   = "xfer_jpeg_50_70.txt";

print "Label:     $label\n";
print "RIG Name:  $rig_name\n";

xdsi::ini_exists($rig_name);

xdsi::rad75_xc_multi($rig_name, $xfer_syntax_path, $uid_path, $label, $test_name);

