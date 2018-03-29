use Env qw(XDSI);
require xdsi;

# This script creates the text information defined by
# Ralph to trigger a RAD-69 transaction.
# The output of this will be read by a client program.
# This script performs the work for a single study. You will
# concatenate the output for multiple studies.

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: homeCommunityId reposUniqueId folder\n" .
    "  homeCommunityId    Home Community ID (urn:oid:1.1....)\n" .
    "  reposUniqueId      Repository Unique ID (1.1....)\n" .
    "  folder             Image folder to scan\n" .
    "  [flag]             If set, omit homeCommunityId and Repository Unique ID\n" 
 if ($arg_count < 3);


my $home_comm_id    =  $ARGV[0];
my $repos_unique_id =  $ARGV[1];
my $folder          =  $ARGV[2];

@images = xdsi::read_folder_recursive($folder);
if ($arg_count == 3) {
 print "#Home Community ID\n";
 print "$home_comm_id\n";
 print "#Repository Unique ID for the IDS\n";
 print "$repos_unique_id\n";
} elsif ($arg_count == 4) {
 if ($ARGV[3] eq "ids") {
  print "#Repository Unique ID for the IDS\n";
  print "$repos_unique_id\n";
 } elsif ($ARGV[3] eq "omit") {
 } else {
  die "Wrong 4th argument to this script: $ARGV[3]\n";
 }
} else {
 die "Wrong number of arguments for this script: $arg_count\n";
}
@uids = xdsi::extract_uids_from_collection(@images);
foreach $u(@uids) {
 print "$u\n";
}


#xdsi::ini_exists($iig_name);
#
#xdsi::rad69_xc_single($pid_dept, $communityA, $communityB, $communityC, $ids_name, $iig_name, $extension, $label, $test_name, "options not used");
#


