#!/usr/bin/perl
use Env qw(XDSI);
require xdsi;

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Usage: ids-rad16-single-01.pl system-name \n" .
    "  system-name   defines parameters for Imaging Document Source\n" if ($arg_count == 0);
my $config_system_under_test = $ARGV[0];

print "\nGenerate a local patient identifier\n";
my $identifier_local = xdsi::generate_identifier_local();

print "\nGenerate a patient identifier in the Affinity Domain\n";
my $identifier_affinity_domain = xdsi::generate_identifier_affinity_domain();

my $uid_study = xdsi::generate_study_uid();
my $accession_number = xdsi::generate_accession_number();

my $patient_name = "Sixteen^Multi";
my $dob = "19930121";
my $sex = "M";
my $study_date = "20151221";

print "\nUse the single image HERE and create a new image with new identifiers\n";
xdsi::generate_new_image_set_full("$XDSI/storage/runtime/$identifier_local/images",
	"$XDSI/storage/reference/IHE-testimages/MR/TCGA-CS-4938",
	$identifier_local, $uid_study, $accession_number,
	$patient_name, $dob, $sex, $study_date);

print "\nUse the new image and create a KOS object\n";
xdsi::generate_kos("$XDSI/storage/runtime/$identifier_local/images", "$XDSI/storage/runtime/$identifier_local/kos", "kos.dcm");
#
#print "\nExamine $ARGV[0] configuration to send RAD-4 scheduling\n";
#xdsi::send_RAD4($config_system_under_test, $identifier_local, $uid_study, $accession_number);

print "\nSend the new single image to the DICOM SCP described in $ARGV[0]\n";
xdsi::send_CSTORE($config_system_under_test, "$XDSI/storage/runtime/$identifier_local/images");

print "\nPrint the local patient identifier for reference\n";
print "Local Identifier: $identifier_local\n";

print "\nPrint the patient identifier from the Affinity Domain for reference\n";
print "AD Identifier:    $identifier_affinity_domain\n";
#
