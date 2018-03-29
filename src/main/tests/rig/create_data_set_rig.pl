use Env qw(XDSI);
use File::Copy;
require xdsi;

sub create_test_data {
 my ($dept_id, $ad_id, $community, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";

 my $path_parent       = "$XDSI/storage/rig/$community";
 my $path_output_images= "$path_parent/$accession_number/images";
 my $path_output_kos   = "$path_parent/$accession_number/kos"; 
 
 my $study_uid = xdsi::generate_study_uid();
 xdsi::generate_new_image_set_full($path_output_images, $path_input_folder,
 	$dept_id, $study_uid, $accession_number, $patient_name, $dob, $sex, $study_date);
 xdsi::generate_kos("$path_output_images", "$path_output_kos", "kos.dcm", "DCM4CHEE", $ad_id, "1.3.6.1.4.1.21367.102.1.1");

 }

sub processOneRow {
  print "$_[0]\n";
  create_test_data(@_);
}

sub processParams {
  my $x = scalar(@_);
  die "Expected a multiple of 9 items, received $x\n" if ($x%9 != 0);
  while (scalar(@_) != 0) {
   my @next_nine = splice(@_, 0, 9);
   processOneRow(@next_nine);
   die ("Early exit") if ($exit_early != 0);
   print "Sleeping for 3 seconds\n";
   sleep 3;
  }
}

# Main starts here

xdsi::check_environment();

print "create_data_set_rig.pl\n";
print "The purpose of this script is to create the test data used to test\n" .
      " the Responding Imaging Gateway actor. This script performs these steps:\n" .
      " + Create imaging studies for a fixed set of patients (known identifiers).\n" .
      " + Create KOS objects for those imaging studies.\n" .
      " + Push imaging studies to the Imaging Document Source (simulator).\n" .
      " + Create XDS metadata for each KOS object.\n";
print "It is a manual step to submit the KOS object to the \n".
      " simulator. Maybe a future version of the script will do this.\n";

      

my $arg_count = scalar(@ARGV);
die "Usage: create_data_set_rig.pl \n" 
if ($arg_count != 0);
$exit_early = 0;


#        $dept_id       $ad_id  $community $patient_name          $dob      $sex  $study_date $accession_number, $in_folder) = @_;
my @params = (
#	"IIG-DEPT2011", "IDSE-2011", "E", "Omega^O",		"19780201", "M", "20150201", "CASCE2011-1", "CR/LIDC-reduced",
#	"IIG-DEPT2011", "IDSE-2011", "E", "Omega^O",		"19780201", "M", "20150202", "CASCE2011-2", "CR/LIDC-reduced",

#	"IIG-DEPT2021", "IDSF-2021", "F", "Psi^P",		"19780202", "M", "20150202", "CASCF2021", "MR/TCGA-CS-4938",

	"IIG-DEPT3041", "IDSE-3041", "E", "Phi^A",		"19780401", "M", "20150401", "CASCE3041-1", "CR/LIDC-reduced",
	"IIG-DEPT3041", "IDSF-3041", "F", "Phi^A",		"19780402", "M", "20150402", "CASCF3041-2", "CR/LIDC-reduced",

);

processParams(@params);

