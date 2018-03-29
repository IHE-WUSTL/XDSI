use Env qw(XDSI);
use File::Copy;
require xdsi;

sub create_test_data {
 my ($dept_id, $ad_id, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";
 my $path_output_images= "$XDSI/storage/idc/$dept_id/images";
 my $path_output_kos   = "$XDSI/storage/idc/$dept_id/kos"; 
 
 my $study_uid = xdsi::generate_study_uid();
 xdsi::generate_new_image_set_full($path_output_images, $path_input_folder,
 	$dept_id, $study_uid, $accession_number, $patient_name, $dob, $sex, $study_date);
 xdsi::generate_kos("$path_output_images", "$path_output_kos", "kos.dcm", "WUSTL", $ad_id);

 }

sub submit_one_study {
 my ($dept_id, $ad_id, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";
 my $path_output_images= "$XDSI/storage/idc/$dept_id/images";
 my $path_output_kos   = "$XDSI/storage/idc/$dept_id/kos"; 
 my $path_toolkit_kos  = "$XDSI/tomcat/apache-tomcat-7.0.65-xdstools2-01/webapps/xdstools2/toolkitx/testkit/testdata-repository/$dept_id";

 xdsi::send_CSTORE($config_ids_simulator, $path_output_images);
 copy ("$path_output_kos/kos.dcm", $path_toolkit_kos) or die "Could not copy kos.dcm from $path_output_kos to $path_toolkit_kos";
 copy ("$path_output_kos/metadata.xml", $path_toolkit_kos) or die "Could not copy metadata.xml from $path_output_kos to $path_toolkit_kos";
}

sub processOneRow {
  print "$_[0]\n";
  create_test_data(@_);
  submit_one_study(@_);
}

sub processParams {
  my $x = scalar(@_);
  die "Expected a multiple of 8 items, received $x\n" if ($x%8 != 0);
  while (scalar(@_) != 0) {
   my @next_eight = splice(@_, 0, 8);
   processOneRow(@next_eight);
   die ("Early exit") if ($exit_early != 0);
  }
}

# Main starts here

xdsi::check_environment();

print "load_data_set_101.pl\n";
print "The purpose of this script is to create the test data used to test\n" .
      " the Imaging Document Consumer actor. This script performs these steps:\n" .
      " + Create imaging studies for a fixed set of patients (known identifiers).\n" .
      " + Create KOS objects for those imaging studies.\n" .
      " + Push imaging studies to the Imaging Document Source (simulator).\n" .
      " + Create XDS metadata for each KOS object.\n";
print "It is a manual step to submit the KOS object to the \n".
      " simulator. Maybe a future version of the script will do this.\n";

      

my $arg_count = scalar(@ARGV);
die "Usage: load_data_set_101.pl system-name \n" .
    "  system-name   defines parameters for Imaging Document Source (simulator)\n" .
    "                (most likely DCM4CHEE-local)\n"
if ($arg_count == 0);
$config_ids_simulator = $ARGV[0];
$exit_early = 0;
$exit_early = 1 if ($arg_count > 1);


my @params = (
	"IDCDEPT001", "IDCAD001", "Computed-Radiography^Single","19780201", "M", "20150201", "IDC001", "CR/LIDC-IDRI",
	"IDCDEPT011", "IDCAD011", "Single^Wado",		"19780211", "M", "20150211", "IDC011", "CR/LIDC-IDRI",
	"IDCDEPT012", "IDCAD012", "Single^Cmove",		"19780212", "M", "20150212", "IDC012", "CR/LIDC-IDRI",
	"IDCDEPT013", "IDCAD013", "Single^Soap",		"19780213", "M", "20150213", "IDC013", "CR/LIDC-IDRI",

	"IDCDEPT021", "IDCAD021", "Multi^Wado",			"19780221", "M", "20150221", "IDC021", "MR/TCGA-CS-4938",
	"IDCDEPT022", "IDCAD022", "Multi^Cmove",		"19780222", "M", "20150222", "IDC022", "MR/TCGA-CS-4938",
	"IDCDEPT023", "IDCAD023", "Multi^Soap",			"19780223", "M", "20150223", "IDC023", "MR/TCGA-CS-4938",

	"IDCDEPT031", "IDCAD031", "Xra^Bert",			"19780301", "M", "20150301", "IDC031", "XA",
	"IDCDEPT032", "IDCAD032", "Ultrasound^Ernie",		"19780302", "M", "20150302", "IDC032", "US",
	"IDCDEPT033", "IDCAD033", "Mammography^Ellen",		"19780303", "F", "20150303", "IDC033", "MG/TCGA-BRCA",
	"IDCDEPT034", "IDCAD034", "Pet^Norman",			"19780304", "M", "20150304", "IDC034", "PT/TCGA-LUSC",
	"IDCDEPT035", "IDCAD035", "Enhanced^MR",		"19780305", "M", "20150305", "IDC035", "MR-enhanced",
	"IDCDEPT036", "IDCAD036", "Enchanced^CT",		"19780306", "M", "20150306", "IDC036", "CT-enhanced",

	"IDCDEPT041", "IDCAD041", "Compressed^Lossless",	"19780401", "M", "20150401", "IDC041", "compressed/lossless",
	"IDCDEPT042", "IDCAD042", "Compressed^Lossy",		"19780402", "M", "20150402", "IDC042", "compressed/lossy",
);

processParams(@params);

