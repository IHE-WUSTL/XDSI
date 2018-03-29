use Env qw(XDSI);
use File::Copy;
require xdsi;

sub create_test_data {
 my ($dept_id, $ad_id, $community, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 my $path_input_folder = "$XDSI/storage/reference/IHE-testimages/$in_folder";

 $dept_id          .= "-" . $extension;
 $ad_id            .= "-" . $extension;
 $patient_name     .= "^" . $extension;
 $accession_number .= "-" . $extension;

 my $path_parent       = "$XDSI/storage/iig/$extension-$community";
 my $path_output_images= "$path_parent/$dept_id/images";
 my $path_output_kos   = "$path_parent/$dept_id/kos"; 
 
 xdsi::generate_kos("$path_output_images", "$path_output_kos", "kos.dcm", "DCM4CHEE", $ad_id, "1.3.6.1.4.1.21367.102.1.1");
 }

sub submit_one_study {
 my ($dept_id, $ad_id, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 $dept_id          .= "-" . $extension;
 my $path_output_kos   = "$XDSI/storage/iig/$extension/$dept_id/kos"; 
# my $path_toolkit_kos  = "$XDSI/tomcat/apache-tomcat-7.0.65-xdstools2-01/webapps/xdstools2/toolkitx/testkit/testdata-repository/$dept_id";
 my $path_toolkit_kos  = "$XDSI/tomcat/apache-tomcat-7.0.65-xdstools2-01/webapps/xdstools2/toolkitx/testkit/testdata-repository/XDS-I";

 mkdir $path_toolkit_kos if (! -e $path_toolkit_kos);

 copy ("$path_output_kos/kos.dcm", "$path_toolkit_kos/kos-$dept_id.dcm") or die "Could not copy kos.dcm from $path_output_kos to $path_toolkit_kos";
 copy ("$path_output_kos/metadata.xml", "$path_toolkit_kos/metadata-$dept_id.xml") or die "Could not copy metadata.xml from $path_output_kos to $path_toolkit_kos";

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

$test_steps .= 
"    <TestStep id=\"submit_doc\">\n" .
"        <ExpectedStatus>Success</ExpectedStatus>\n" .
"        <ProvideAndRegisterTransaction>\n" .
"            <XDSb/>\n" .
"            <AssignUuids/>\n" .
"            <NoPatientId/>\n" .
"            <MetadataFile>metadata-$dept_id.xml</MetadataFile>\n" .
"            <Document id=\"Document01\">kos-$dept_id.dcm</Document>\n" .
"        </ProvideAndRegisterTransaction>\n" .
"    </TestStep>\n" ;


# open F, ">$path_toolkit_kos/testplan.xml" or die "Could not create XDS testplan file: $path_toolkit_kos/testplan.xml";
# print F $testplan;
# close F;
 open G, ">$path_output_kos/testplan.xml" or die "Could not create XDS testplan file: $path_toolkit_kos/testplan.xml";
 print G $testplan;
 close G;
}

sub write_test_plan {
 my $path_toolkit  = "$XDSI/tomcat/apache-tomcat-7.0.65-xdstools2-01/webapps/xdstools2/toolkitx/testkit/testdata-repository/XDS-I-ids-$extension";

 mkdir $path_toolkit_kos if (! -e $path_toolkit_kos);

my $testplan_opening = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" .
"<TestPlan>\n" .
"    <Test>XDSIDocumentLoad</Test>\n";

my $testplan_closing = 
"</TestPlan>\n";

 open F, ">$path_toolkit/testplan.xml" or die "Could not create XDS testplan file: $path_toolkit_kos/testplan.xml";
 print F $testplan_opening;
 print F $test_steps;
 print F $testplan_closing;
 close F;
}

sub processOneRow {
  print "$_[0]\n";
  create_test_data(@_);
#  submit_one_study(@_);
}

sub processParams {
  my $x = scalar(@_);
  die "Expected a multiple of 9 items, received $x\n" if ($x%9 != 0);
  while (scalar(@_) != 0) {
   my @next_nine = splice(@_, 0, 9);
   processOneRow(@next_nine);
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
die "Usage: create_kos_and_metadata.pl extension\n" .
    "  extension     The name of the extension for this dataset (a, b, c, ...)\n"
if ($arg_count == 0);
$extension = $ARGV[0];
$exit_early = 0;
$exit_early = 1 if ($arg_count > 1);


my @params = (
	"IIG-DEPT1011",  "CA1011", "A", "Alpha^A",		"19780201", "M", "20150201", "CASCA1011", "CR/LIDC-reduced",
	"IIG-DEPT1021",  "CB1021", "B", "Beta^B",		"19780202", "M", "20150202", "CASCB1021", "MR/TCGA-CS-4938",
	"IIG-DEPT1031a", "CA1031", "A", "Gamma^G",		"19780203", "M", "20150203", "CASCA1031", "CR/LIDC-reduced",
	"IIG-DEPT1031b", "CB1031", "B", "Gamma^G",		"19780203", "M", "20150204", "CASCB1031", "MR/TCGA-CS-4938",

);

$test_steps = "";

processParams(@params);
#write_test_plan();

