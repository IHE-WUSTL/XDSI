use Env qw(XDSI);
require xdsi;

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Usage: ids-rad16-single-05.pl LOCAL_ID AFFINITY-DOMAIN_ID C-Move_SCP_Name [simulator-name] \n" .
    "  LOCAL_ID           Patient identifier for departmental (local) work\n" .
    "  AFFINITY-DOMAIN_ID Patient identifier for Affinity Domain\n" .
    "  C-Move_SCP_Name    Name of the C-Move SCP (for a .ini file)\n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xdsi01__rep-reg\n"
 if ($arg_count == 0);

my $cmove_name = $ARGV[2];
my $simulator = "xdsi01__rep-reg";
$simulator = $ARGV[3] if (scalar(@ARGV) > 3);

print "Local ID:  $ARGV[0]\n";
print "AD ID:     $ARGV[1]\n";
print "CMove:     $cmove_name\n";
print "Simulator: $simulator\n";


xdsi::validate_rad16(@ARGV);


