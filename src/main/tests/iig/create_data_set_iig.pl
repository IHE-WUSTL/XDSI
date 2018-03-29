use Env qw(XDSI);
use File::Copy;
require xdsi;

sub create_test_data {
 my ($dept_id, $ad_id, $community, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";

# $dept_id          .= "-" . $extension;
# $ad_id            .= "-" . $extension;
# $patient_name     .= "^" . $extension;
# $accession_number .= "-" . $extension;

 my $path_parent       = "$XDSI/storage/iig/$community";
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

print "create_data_set_iig.pl\n";
print "The purpose of this script is to create the test data used to test\n" .
      " the Initiating Imaging Gateway actor. This script performs these steps:\n" .
      " + Create imaging studies for a fixed set of patients (known identifiers).\n" .
      " + Create KOS objects for those imaging studies.\n" .
      " + Push imaging studies to the Imaging Document Source (simulator).\n" .
      " + Create XDS metadata for each KOS object.\n";
print "It is a manual step to submit the KOS object to the \n".
      " simulator. Maybe a future version of the script will do this.\n";

      

my $arg_count = scalar(@ARGV);
die "Usage: create_data_set_iig.pl \n" 
if ($arg_count != 0);
$exit_early = 0;


#        $dept_id       $ad_id $community $patient_name          $dob      $sex  $study_date $accession_number, $in_folder) = @_;
my @params = (
	"IIG-DEPT1011", "CA1011", "A", "Alpha^A",		"19780201", "M", "20150201", "CASCA1011-1", "CR/LIDC-reduced",
	"IIG-DEPT1011", "CA1011", "A", "Alpha^A",		"19780201", "M", "20150202", "CASCA1011-2", "CR/LIDC-reduced",
	"IIG-DEPT1021", "CB1021", "B", "Beta^B",		"19780202", "M", "20150202", "CASCB1021", "MR/TCGA-CS-4938",
	"IIG-DEPT1031", "CA1031", "A", "Gamma^G",		"19780203", "M", "20150203", "CASCA1031", "CR/LIDC-reduced",
	"IIG-DEPT1031", "CB1031", "B", "Gamma^G",		"19780203", "M", "20150204", "CASCB1031", "MR/TCGA-CS-4938",

#	"IDS-DEPT003", "IDS-AD003", "Multi^Ct",			"19780203", "M", "20150203", "IDC003", "CT/0522c0154",
#	"IDS-DEPT011", "IDS-AD011", "Transactions^Mr",		"19780211", "M", "20150211", "IDC011", "MR/TCGA-CS-4938",
#	"IDS-DEPT012", "IDS-AD012", "Enhanced^MR",		"19780212", "M", "20150212", "IDC012", "MR-enhanced",
#	"IDS-DEPT021", "IDS-AD021", "Xra^William",		"19780321", "M", "20150321", "IDC021", "XA",
#	"IDS-DEPT022", "IDS-AD022", "Ultrasound^Will",		"19780322", "M", "20150322", "IDC022", "US",
#	"IDS-DEPT023", "IDS-AD023", "Mammography^Ellen",	"19780323", "F", "20150323", "IDC023", "MG/TCGA-BRCA",
#	"IDS-DEPT024", "IDS-AD024", "Pet^Scout",		"19780324", "M", "20150324", "IDC024", "PT/TCGA-LUSC",
#	"IDS-DEPT025", "IDS-AD025", "Enhanced^MR",		"19780325", "M", "20150325", "IDC025", "MR-enhanced",
#	"IDS-DEPT026", "IDS-AD026", "Enchanced^CT",		"19780326", "M", "20150326", "IDC026", "CT-enhanced",
#	"IDS-DEPT027", "IDS-AD027", "Multi^Pat",		"19780327", "M", "20150327", "IDC027", "1study2modalities",
#	"IDS-DEPT041", "IDS-AD041", "Compressed^Lossless",	"19780401", "M", "20150401", "IDC041", "compressed/lossless",
#	"IDS-DEPT042", "IDS-AD042", "Compressed^Lossy",		"19780402", "M", "20150402", "IDC042", "compressed/lossy",
);

processParams(@params);

