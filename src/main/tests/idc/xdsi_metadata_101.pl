use Env qw(XDSI);
use File::Copy;
require xdsi;

sub create_xdsi_xml_data {
 my ($dept_id, $ad_id, $patient_name, $dob, $sex, $study_date, $accession_number, $in_folder) = @_;
 my $path_kos         = "$XDSI/storage/idc/$dept_id/kos/kos.dcm"; 
 my $path_full        = "$XDSI/storage/idc/$dept_id/kos/full_retrieve_request.xml"; 
 my $path_study_xfer  = "$XDSI/storage/idc/$dept_id/kos/study_transfer_only.xml"; 
 
 xdsi::generate_rad69_data($path_full, $path_study_xfer, $path_kos, $repository_unique_id);
}


sub processOneRow {
  print "$_[0]\n";
  create_xdsi_xml_data(@_);
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
print "The purpose of this script is to create the XML used for a RAD-69 transaction\n" .
      " based on the UIDs found in one KOS object.\n";

my $arg_count = scalar(@ARGV);
die "Usage: xdsi_metadata_101.pl Repository-Unique-Id \n" .
    "  Repository-Unique-Id  Goes in the output xml to identify the Imaging Document Source\n"
if ($arg_count == 0);
$repository_unique_id = $ARGV[0];
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

