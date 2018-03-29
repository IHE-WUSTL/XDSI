use Env qw(XDSI);
require xdsi;

# This script performs Rad-69 retrieve from an Imaging Initiating Gateway.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension ids_name simulator-name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  ids_name           Name of the IDS (for a .ini file)\n" .
    "  iig_name           Name of the IIG (for a .ini file)\n"
 if ($arg_count != 3);

my $label      =  $ARGV[0];
my $ids_name   =  $ARGV[1];
my $iig_name   =  $ARGV[2];
my $test_name  = "iig-1003";
my $uid_path   = "../tests/iig/iig-1003/iig-1003.txt";
my $xfer_syntax_path   = "xfer_jpeg_lossless.txt";

print "Label:     $label\n";
print "IDS Name:  $ids_name\n";
print "IIG Name:  $iig_name\n";

xdsi::ini_exists($iig_name);

xdsi::rad69_xc_multi($ids_name, $iig_name, $xfer_syntax_path, $uid_path, $label, $test_name);

