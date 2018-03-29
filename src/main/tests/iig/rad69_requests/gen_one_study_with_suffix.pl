use Env qw(XDSI);
require xdsi;

# This script creates the text information defined by
# Ralph to trigger a RAD-69 transaction.
# The output of this will be read by a client program.
# This script performs the work for a single study. You will
# concatenate the output for multiple studies.
# This script takes a suffix variable that is appended to the
# SOP instance UID to simulate an error in UIDs

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: homeCommunityId reposUniqueId folder suffix\n" .
    "  homeCommunityId    Home Community ID (urn:oid:1.1....)\n" .
    "  reposUniqueId      Repository Unique ID (1.1....)\n" .
    "  folder             Image folder to scan\n"  .
    "  suffix             Suffix to add to the SOP Instance UID\n" .
    "  [flag]             If set, omit homeCommunitId and RepositoryUniqueiD\n"  
 if ($arg_count < 4);


my $home_comm_id    =  $ARGV[0];
my $repos_unique_id =  $ARGV[1];
my $folder          =  $ARGV[2];
my $suffix          =  $ARGV[3];

@images = xdsi::read_folder_recursive($folder);

if ($arg_count == 4) {
 print "#Home Community ID\n";
 print "$home_comm_id\n";
 print "#Repository Unique ID for the IDS\n";
 print "$repos_unique_id\n";
} elsif ($arg_count == 5) {
 if ($ARGV[4] eq "ids") {
  print "#Repository Unique ID for the IDS\n";
  print "$repos_unique_id\n";
 } elsif ($ARGV[4] eq "omit") {
 } else {
  die "Wrong 5th argument to this script: $ARGV[4]\n";
 }
} else {
 die "Wrong number of arguments for this script: $arg_count\n";
}






@uids = xdsi::extract_uids_from_collection(@images);
foreach $u(@uids) {
 print "$u". "$suffix\n";
}


#xdsi::ini_exists($iig_name);
#
#xdsi::rad69_xc_single($pid_dept, $communityA, $communityB, $communityC, $ids_name, $iig_name, $extension, $label, $test_name, "options not used");
#


