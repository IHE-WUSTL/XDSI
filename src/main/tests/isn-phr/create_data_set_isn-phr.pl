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

 my $path_output_base = "$XDSI/storage/isn-phr/$extension/$dept_id/$accession_number";

 my $path_output_images= "$path_output_base/images";
 my $path_output_kos   = "$path_output_base/kos"; 
 
 my $study_uid = xdsi::generate_study_uid();
 xdsi::generate_new_image_set_full($path_output_images, $path_input_folder,
 	$dept_id, $study_uid, $accession_number, $patient_name, $dob, $sex, $study_date);
 xdsi::generate_kos("$path_output_images", "$path_output_kos", "kos.dcm", "WUSTL", $ad_id);

 }

sub submit_one_study {
# my ($dept_id, $ad_id, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
# $dept_id          .= "-" . $extension;
## my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";
## my $path_output_images= "$XDSI/storage/isn-phr/$extension/$dept_id/images";
# my $path_output_kos   = "$XDSI/storage/isn-phr/$extension/$dept_id/kos"; 
# my $path_toolkit_kos  = "$XDSI/tomcat/apache-tomcat-7.0.65-xdstools2-01/webapps/xdstools2/toolkitx/testkit/testdata-repository/$dept_id";
#
# mkdir $path_toolkit_kos if (! -e $path_toolkit_kos);
#
## xdsi::send_CSTORE($config_ids_simulator, $path_output_images);
# copy ("$path_output_kos/kos.dcm", $path_toolkit_kos) or die "Could not copy kos.dcm from $path_output_kos to $path_toolkit_kos";
# copy ("$path_output_kos/metadata.xml", $path_toolkit_kos) or die "Could not copy metadata.xml from $path_output_kos to $path_toolkit_kos";
#
#my $testplan = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" .
#"<TestPlan>\n" .
#"    <Test>SingleDocument</Test>\n" .
#"    <TestStep id=\"submit_doc\">\n" .
#"        <ExpectedStatus>Success</ExpectedStatus>\n" .
#"        <ProvideAndRegisterTransaction>\n" .
#"            <XDSb/>\n" .
#"            <AssignUuids/>\n" .
#"            <NoPatientId/>\n" .
#"            <MetadataFile>metadata.xml</MetadataFile>\n" .
#"            <Document id=\"Document01\">kos.dcm</Document>\n" .
#"        </ProvideAndRegisterTransaction>\n" .
#"    </TestStep>\n" .
#"</TestPlan>\n";
#
# open F, ">$path_toolkit_kos/testplan.xml" or die "Could not create XDS testplan file: $path_toolkit_kos/testplan.xml";
# print F $testplan;
# close F;
# open G, ">$path_output_kos/testplan.xml" or die "Could not create XDS testplan file: $path_toolkit_kos/testplan.xml";
# print G $testplan;
# close G;
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
      " the ISN PHR actor. This script performs these steps:\n" .
      " + Create imaging studies for a fixed set of patients (known identifiers).\n" .
      " + Create KOS objects for those imaging studies.\n" .
      " + Create XDS metadata for each KOS object.\n";
print "It is a manual step to submit the KOS object to the \n".
      " simulator. Maybe a future version of the script will do this.\n";

my $arg_count = scalar(@ARGV);
die "\nUsage: create_data_set_isn-phr.pl extension\n" .
    "  extension     The name of the extension for this dataset (a, b, c, ...)\n"
if ($arg_count == 0);
$extension = $ARGV[0];
$exit_early = 0;
$exit_early = 1 if ($arg_count > 1);


my @params = (
 "ISNPHR-DEPT001", "ISNPHR-AD001", "Computed-Rad^Single",  "19850101", "M", "20150201", "ISNPHR-001", "CR/LIDC-IDRI",
 "ISNPHR-DEPT002", "ISNPHR-AD002", "Magres^Mr",		   "19850102", "M", "20150202", "ISNPHR-002", "MR/TCGA-CS-4938",
 "ISNPHR-DEPT021", "ISNPHR-AD021", "Xra^William",	   "19860201", "M", "20150321", "ISNPHR-021", "XA",
 "ISNPHR-DEPT022", "ISNPHR-AD022", "Ultrasound^Will",      "19860202", "M", "20150322", "ISNPHR-022", "US",
 "ISNPHR-DEPT023", "ISNPHR-AD023", "Mammography^Ellen",    "19860203", "F", "20150323", "ISNPHR-023", "MG/TCGA-BRCA",
 "ISNPHR-DEPT024", "ISNPHR-AD024", "Pet^Scout",		   "19860204", "M", "20150324", "ISNPHR-024", "PT/TCGA-LUSC",
 "ISNPHR-DEPT025", "ISNPHR-AD025", "Enhanced^Mag",	   "19860205", "M", "20150212", "ISNPHR-025", "MR-enhanced",
 "ISNPHR-DEPT026", "ISNPHR-AD026", "Enchanced^Comp",	   "19860206", "M", "20150326", "ISNPHR-026", "CT-enhanced",
 "ISNPHR-DEPT027", "ISNPHR-AD027", "Multi^Pat",		   "19860207", "M", "20150327", "ISNPHR-027", "1study2modalities",
 "ISNPHR-DEPT041", "ISNPHR-AD041", "Compressed^Lossless",  "19870401", "M", "20150401", "ISNPHR-041", "compressed/lossless",
 "ISNPHR-DEPT042", "ISNPHR-AD042", "Compressed^Lossy",     "19870402", "M", "20150402", "ISNPHR-042", "compressed/lossy",

# The next three entries are for a single patient with multiple imaging studies
 "ISNPHR-DEPT051", "ISNPHR-AD051", "Several^Pat",	   "19880501", "M", "20150501", "ISNPHR-051z","CR/LIDC-IDRI",
 "ISNPHR-DEPT051", "ISNPHR-AD051", "Several^Pat",	   "19880501", "M", "20150502", "ISNPHR-051y","MR/TCGA-CS-4938",
 "ISNPHR-DEPT051", "ISNPHR-AD051", "Several^Pat",	   "19880501", "M", "20150503", "ISNPHR-051x","CT/0522c0154",

 "ISNPHR-DEPT061", "ISNPHR-AD061", "Report^None",	   "19890601", "M", "20150601", "ISNPHR-061", "CR/LIDC-IDRI",
 "ISNPHR-DEPT062", "ISNPHR-AD062", "Kos^None",		   "19890602", "M", "20150602", "ISNPHR-062", "CR/LIDC-IDRI",
 "ISNPHR-DEPT063", "ISNPHR-AD063", "Birth^Wrong",	   "19890603", "M", "20150603", "ISNPHR-063", "CR/LIDC-IDRI",
 "ISNPHR-DEPT064", "ISNPHR-AD064", "Access^Wrong",	   "19890604", "M", "20150604", "ISNPHR-064", "CR/LIDC-IDRI",
 "ISNPHR-DEPT065", "ISNPHR-AD065", "Images^None",	   "19890605", "M", "20150605", "ISNPHR-065", "CR/LIDC-IDRI",
 "ISNPHR-DEPT066", "ISNPHR-AD066", "Images^Incomplete",    "19890606", "M", "20150606", "ISNPHR-066", "MR/TCGA-CS-4938",

);

processParams(@params);

