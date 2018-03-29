use Env qw(XDSI);
use File::Copy;
require xdsi;

sub create_test_data {
 my ($dept_id, $ad_id, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";

 $dept_id          .= "-" . $extension;
 $ad_id            .= "-" . $extension;
 $patient_name     .= "^" . $extension;
 $accession_number .= "-" . $extension;

 my $path_output_images= "$XDSI/storage/ids/$extension/$dept_id/images";
 my $path_output_kos   = "$XDSI/storage/ids/$extension/$dept_id/kos"; 
 
 my $study_uid = xdsi::generate_study_uid();
 xdsi::generate_new_image_set_full($path_output_images, $path_input_folder,
 	$dept_id, $study_uid, $accession_number, $patient_name, $dob, $sex, $study_date);
 xdsi::generate_kos("$path_output_images", "$path_output_kos", "kos.dcm", "DCM4CHEE", $ad_id, "1.3.6.1.4.1.21367.102.1.1");

 }

sub submit_one_study {
 my ($dept_id, $ad_id, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 $dept_id          .= "-" . $extension;
# my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";
# my $path_output_images= "$XDSI/storage/ids/$extension/$dept_id/images";
 my $path_output_kos   = "$XDSI/storage/ids/$extension/$dept_id/kos"; 
 my $path_toolkit_kos  = "$XDSI/tomcat/apache-tomcat-7.0.65-xdstools2-01/webapps/xdstools2/toolkitx/testkit/testdata-repository/$dept_id";

 mkdir $path_toolkit_kos if (! -e $path_toolkit_kos);

# xdsi::send_CSTORE($config_ids_simulator, $path_output_images);
 copy ("$path_output_kos/kos.dcm", $path_toolkit_kos) or die "Could not copy kos.dcm from $path_output_kos to $path_toolkit_kos";
 copy ("$path_output_kos/metadata.xml", $path_toolkit_kos) or die "Could not copy metadata.xml from $path_output_kos to $path_toolkit_kos";

my $testplan = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" .
"<TestPlan>\n" .
"    <Test>SingleDocument</Test>\n" .
"    <TestStep id=\"submit_doc\">\n" .
"        <ExpectedStatus>Success</ExpectedStatus>\n" .
"        <ProvideAndRegisterTransaction>\n" .
"            <XDSb/>\n" .
"            <AssignUuids/>\n" .
"            <NoPatientId/>\n" .
"            <MetadataFile>metadata.xml</MetadataFile>\n" .
"            <Document id=\"Document01\">kos.dcm</Document>\n" .
"        </ProvideAndRegisterTransaction>\n" .
"    </TestStep>\n" .
"</TestPlan>\n";

 open F, ">$path_toolkit_kos/testplan.xml" or die "Could not create XDS testplan file: $path_toolkit_kos/testplan.xml";
 print F $testplan;
 close F;
 open G, ">$path_output_kos/testplan.xml" or die "Could not create XDS testplan file: $path_toolkit_kos/testplan.xml";
 print G $testplan;
 close G;
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
die "Usage: create_data_set_ids.pl extension\n" .
    "  extension     The name of the extension for this dataset (a, b, c, ...)\n"
if ($arg_count == 0);
$extension = $ARGV[0];
$exit_early = 0;
$exit_early = 1 if ($arg_count > 1);


my @params = (
	"IDS-DEPT001", "IDS-AD001", "Computed-Rad^Single",	"19780201", "M", "20150201", "IDS001", "CR/LIDC-IDRI",
	"IDS-DEPT002", "IDS-AD002", "Multi^Mr",			"19780202", "M", "20150202", "IDC002", "MR/TCGA-CS-4938",
	"IDS-DEPT003", "IDS-AD003", "Multi^Ct",			"19780203", "M", "20150203", "IDC003", "CT/0522c0154",
	"IDS-DEPT011", "IDS-AD011", "Transactions^Mr",		"19780211", "M", "20150211", "IDC011", "MR/TCGA-CS-4938",
	"IDS-DEPT012", "IDS-AD012", "Enhanced^MR",		"19780212", "M", "20150212", "IDC012", "MR-enhanced",
	"IDS-DEPT021", "IDS-AD021", "Xra^William",		"19780321", "M", "20150321", "IDC021", "XA",
	"IDS-DEPT022", "IDS-AD022", "Ultrasound^Will",		"19780322", "M", "20150322", "IDC022", "US",
	"IDS-DEPT023", "IDS-AD023", "Mammography^Ellen",	"19780323", "F", "20150323", "IDC023", "MG/TCGA-BRCA",
	"IDS-DEPT024", "IDS-AD024", "Pet^Scout",		"19780324", "M", "20150324", "IDC024", "PT/TCGA-LUSC",
	"IDS-DEPT025", "IDS-AD025", "Enhanced^MR",		"19780325", "M", "20150325", "IDC025", "MR-enhanced",
	"IDS-DEPT026", "IDS-AD026", "Enchanced^CT",		"19780326", "M", "20150326", "IDC026", "CT-enhanced",
	"IDS-DEPT027", "IDS-AD027", "Multi^Pat",		"19780327", "M", "20150327", "IDC027", "1study2modalities",
	"IDS-DEPT041", "IDS-AD041", "Compressed^Lossless",	"19780401", "M", "20150401", "IDC041", "compressed/lossless",
	"IDS-DEPT042", "IDS-AD042", "Compressed^Lossy",		"19780402", "M", "20150402", "IDC042", "compressed/lossy",
);

processParams(@params);

