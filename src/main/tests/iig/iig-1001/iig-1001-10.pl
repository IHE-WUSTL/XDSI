use Env qw(XDSI);
require xdsi;

# This script performs Rad-69 retrieve from an Imaging Initiating Gateway.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension rig_name simulator-name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  rig_name           Name of the RIG (for a .ini file)\n" .
    "  iig_name           Name of the IIG (for a .ini file)\n"
 if ($arg_count != 3);

my $label      =  $ARGV[0];
my $rig_name   =  $ARGV[1];
my $iig_name   =  $ARGV[2];
my $test_name  = "iig-1001";
my $uid_path   = "../tests/iig/iig-1001/iig-1001.txt";
my $xfer_syntax_path   = "xfer_vrle.txt";

print "Label:     $label\n";
print "RIG Name:  $rig_name\n";
print "IIG Name:  $iig_name\n";

xdsi::ini_exists($iig_name);

xdsi::rad69_xc_multi($rig_name, $iig_name, $xfer_syntax_path, $uid_path, $label, $test_name);
