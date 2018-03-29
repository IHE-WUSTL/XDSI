use Env qw(XDSI);
require xdsi;

# This script performs a number of RAD-55 retrieves from an 
# Imaging Document Source. These are exception cases that are
# normally expected to not return an image.

# Case 2: Unknown SOP Instance UID
sub construct_case_2 {
 return "$uids_study_2[0]:$uids_study_2[1]:$uids_study_2[2]" . ".987654" .
	"=" . $ids_name . 
	"=" . "$XDSI/runDirectory/xfer_vrle.txt";
}

# Case 3: SOP Instance is from a different series in this study
sub construct_case_3 {
 return "$uids_study_2[0]:$uids_study_2[1]:$uids_study_3[2]" .
	"=" . $ids_name . 
	"=" . "$XDSI/runDirectory/xfer_vrle.txt";
}

# Case 4: SOP Instance is from a different study
sub construct_case_4 {
 return "$uids_study_1[0]:$uids_study_1[1]:$uids_study_3[2]" .
	"=" . $ids_name . 
	"=" . "$XDSI/runDirectory/xfer_vrle.txt";
}

# Case 5: Study Instance is empty
sub construct_case_5 {
 return ":$uids_study_2[1]:$uids_study_2[2]" .
	"=" . $ids_name . 
	"=" . "$XDSI/runDirectory/xfer_vrle.txt";
}

# Case 6: Series Instance UID is empty
sub construct_case_6 {
 return "$uids_study_2[0]::$uids_study_2[2]" .
	"=" . $ids_name . 
	"=" . "$XDSI/runDirectory/xfer_vrle.txt";
}

# Case 7: Study and Series Instance UIDs are empty
sub construct_case_7 {
 return "::$uids_study_2[2]" .
	"=" . $ids_name . 
	"=" . "$XDSI/runDirectory/xfer_vrle.txt";
}

sub construct_test_cases {
 my @params;
 my $idx = 0;
 $params[$idx++] = construct_case_2();
 $params[$idx++] = construct_case_3();
 $params[$idx++] = construct_case_4();
 $params[$idx++] = construct_case_5();
 $params[$idx++] = construct_case_6();
 $params[$idx++] = construct_case_7();
 return @params;
}

sub run_test_case {
 my($extension, $label, $test_name, $sub_label, $p) = @_;
 print "run_test_case $p\n";
 my (@tokens) = split(/=/, $p);
 my $uids = $tokens[0];
 my $repos_id = $tokens[1];
 my $xfer_path = $tokens[2];

 xdsi::rad55_single_exception("pid_dept", "pid_ad", "sim_name", $ids_name, $extension, $label, $test_name, $sub_label, $uids);
}

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension simulator-name ids_name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  extension          Specifies test data set (a, b, c, ...) \n" .
    "  simulator-name     Name of the XDS.b Rep/Reg. Probably xxx__rep-reg\n" .
    "  ids_name           Name of the IDS configuration (for a .ini file)\n"
 if ($arg_count != 4);


$label     =  $ARGV[0];
$extension =  $ARGV[1];
$simulator =  $ARGV[2];
$ids_name   = $ARGV[3];
$pid_dept  = "IDS-DEPT001-$extension";
$pid_ad    = "IDS-AD001-$extension";
$test_name = "ids-rad55-exception";


print "Label:     $label\n";
print "Extension: $extension\n";
print "Local ID:  $pid_dept\n";
print "AD ID:     $pid_ad\n";
print "IDS Name:  $ids_name  \n";
print "Simulator: $simulator\n";

#xdsi::rad69_single($pid_dept, $pid_ad, $simulator, $ids_name,  $extension, $label, $test_name, "STUDY:SERIES:INSTANCE");

(@uids_study_1) = xdsi::extract_uids("$XDSI/storage/ids/$extension/IDS-DEPT001-$extension/images/000000.dcm");
(@uids_study_2) = xdsi::extract_uids("$XDSI/storage/ids/$extension/IDS-DEPT002-$extension/images/000000.dcm");
(@uids_study_3) = xdsi::extract_uids("$XDSI/storage/ids/$extension/IDS-DEPT002-$extension/images/000020.dcm");

(@retrieve_parameters) = construct_test_cases($ids_name);

my $sub_label = 101;
foreach $p(@retrieve_parameters) {
  run_test_case($extension, $label, $test_name, $sub_label, $p);
  $sub_label++;
}


