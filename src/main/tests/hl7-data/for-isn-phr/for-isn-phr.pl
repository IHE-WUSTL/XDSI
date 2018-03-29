#!/usr/local/bin/perl -w

use Env;
use File::Copy;
use lib "../common";
use lib "../../common";
require mesa_msgs;
require image_sharing;
require xdsi;

sub write_fixed_key_values {
 my $path = shift;

 open F, ">$path" or die "Could not open $f for output";

 my $dt = image_sharing::generate_date_time();

 print F "\$DATE_TIME\$ = $dt\n";
 print F "\$ORDER_EFFECTIVE_DATE\$ = $dt\n";
 print F "\$UPDATE_DATE_TIME\$ = $dt\n";
 print F "\$MESSAGE_CONTROL_ID\$ = $dt\n";
 print F "\$CHARSET\$ = ####\n";

 print F "#ORC\n" .
	"\$ORDER_CONTROL\$ = NW\n" .
	"\$ORDER_STATUS\$ = SC\n" .
	"\$QUANTITY_TIMING\$ = 1^once^^^^S\n" .
	"\$ENTERED_BY\$ = ^ROSEWOOD^RANDOLPH\n" .
	"\$ORDERING_PROVIDER\$ = 7101^ESTRADA^JAIME^P^^DR\n" .
	"\$CALL_BACK_PHONE_NUMBER\$ = ####\n" .
	"\$ENTERING_ORGANIZATION\$ = 922229-10^IHE-RAD^IHE-CODE-231\n" .
	#OBR\n" .
	"\$SETID_OBR\$ = 1\n" ;

 print F "# PV1\n" .
	"\$PATIENT_CLASS\$ = O\n" .
	"\$PATIENT_LOCATION\$ = ####\n" .
	"\$ATTENDING_DOCTOR\$ = ####\n" .
	"\$REFERRING_DOCTOR\$ = 5101^NELL^FREDERICK^P^^DR\n" .
	"\$HOSPITAL_SERVICE\$ = ####\n" .
	"\$ADMITTING_DOCTOR\$ = ####\n" .
	"\$ADMIT_DATE_TIME\$ = 201603041645\n" .
	"\$VISIT_INDICATOR\$ = V\n" ;

 close F;
}


#sub get_demographics {
# my ($pid, $extension) = @_;
#
# my %m = (
#	"ISNPHR-DEPT-001", "19850101:M:Computed-Rad^Single",
#	"ISNPHR-DEPT-002", "19850102:M:Multi^Mr",
#	"ISNPHR-DEPT-021", "19860201:M:Xra^William",
#	"ISNPHR-DEPT-022", "19860202:M:Ultrasound^Will",
#	"ISNPHR-DEPT-023", "19860203:F:Mammography^Ann",
#	"ISNPHR-DEPT-024", "19860204:F:Pet^Scout",
#	"ISNPHR-DEPT-025", "19860205:M:Enhanced^Mag",
#	"ISNPHR-DEPT-026", "19860206:M:Enhanced^Comp",
#	"ISNPHR-DEPT-027", "19860207:F:Multi^Pat",
#	"ISNPHR-DEPT-041", "19870401:M:Compressed^Lossless",
#	"ISNPHR-DEPT-042", "19870401:F:Compressed^Lossy",
#	"ISNPHR-DEPT-051", "19880501:F:Several^Pat",
#	);
#
# my $patient = $m{$pid};
# my @tokens = split (":", $patient);
#
# my $demog =
#	"\$PATIENT_ID\$ = $pid-$extension^^^RSNA-Test\n" .
#	"\$PATIENT_ADDRESS\$ = $pid E Adams^^Washington^AL^41001\n" .
#	"\$PATIENT_ACCOUNT_NUM\$ = $pid-$extension\n" .
#	"\$PATIENT_NAME\$ = $tokens[2]^$extension\n" .
#	"\$DATE_TIME_BIRTH\$ = $tokens[0]\n" .
#	"\$SEX\$ = $tokens[1]\n" .
#	"\$RACE\$ = AP\n";
#
# return $demog;
#
#}

sub write_message_variables {
 my ($path, $pid, $extension) = @_;

 open F, ">$path" or die "Could not open $f for output";
 my $dt = image_sharing::generate_date_time();

 print F "\$MESSAGE_CONTROL_ID\$ = $dt\n";
 print F "\$CHAR_SET\$ = ####\n";
 $demog = get_demographics($pid, $extension);

 print F "# PID\n";
 print F $demog;

 print F "# PV1\n" .
	"\$PATIENT_CLASS\$ = O\n" .
	"\$PATIENT_LOCATION\$ = ####\n" .
	"\$ATTENDING_DOCTOR\$ = ####\n" .
	"\$REFERRING_DOCTOR\$ = 5101^NELL^FREDERICK^P^^DR\n" .
	"\$HOSPITAL_SERVICE\$ = ####\n" .
	"\$ADMITTING_DOCTOR\$ = ####\n" .
	"\$VISIT_NUMBER\$ = V$pid-$extension\n" .
	"\$ADMIT_DATE_TIME\$ = 201603041645\n" .
	"\$VISIT_INDICATOR\$ = V\n" ;

 print F "# OBR\n\n" .
	"\$SETID_OBR\$ = 1\n" .
	"\$UNIVERSAL_SERVICE_ID\$ = K99^Head MR^RSNA-Test^K99_A1^Head MR Protocol Item 1^RSNA-Test\n" .
	"\$RELEVANT_CLINICAL_INFO\$ = xxx\n" .
	"\$SPECIMEN_SOURCE\$ = Radiology^^^^R^\n" .
	"\$TRANSPORTATION_MODE\$ = WALK\n" .
	"\$TRANSPORT_ARRANGED\$ = A\n" .
	"\$DIAG_SERV_SECT\$ = MR\n" .
	"\$PROCEDURE_CODE\$ = K99^Head MR^RSNA-Test\n" .
	"\$ACCESSION_NUMBER\$ = A-$pid-$extension\n" .
	"\$REQUESTED_PROCEDURE_ID\$ = R-$pid-$extension\n" .
	"\$SCHEDULED_PROCEDURE_STEP_ID\$ = S-$pid-$extension\n" ;
 close F;
}

sub write_study_key_values {
 my ($path, $demog_string, $study_identifiers) = @_;

 open F, ">$path" or die "Could not open $f for output";
 print F "# Demographics\n" . $demog_string;
 print F "# Study Identifiers\n" . $study_identifiers;
 close F;

}

sub get_demographics {
 my ($hl7_folder, $kos_path) = @_;
 my $patient_name = xdsi::extract_one_field($kos_path, "0010,0010");
 my $patient_id   = xdsi::extract_one_field($kos_path, "0010,0020");
 my $dob          = xdsi::extract_one_field($kos_path, "0010,0030");
 my $sex          = xdsi::extract_one_field($kos_path, "0010,0040");
 my $accession_number = xdsi::extract_one_field($kos_path, "0008,0050");

 my $demog =
	"\$PATIENT_ID\$ = $patient_id^^^RSNA-Test\n" .
	"\$PATIENT_ADDRESS\$ = $patient_id E Adams^^Washington^AL^41001\n" .
	"\$PATIENT_ACCOUNT_NUM\$ = $patient_id\n" .
	"\$VISIT_NUMBER\$ = V$accession_number\n" .
	"\$PATIENT_NAME\$ = $patient_name\n" .
	"\$DATE_TIME_BIRTH\$ = $dob\n" .
	"\$SEX\$ = $sex\n" .
	"\$RACE\$ = AP\n";

 return $demog;
}

sub lookup_procedure {
 my ($modality) = @_;

 my $us_id = "K099^Head MR^RSNA-Test^K99_A1^Head MR Protocol Item 1^RSNA-Test";
 my $proc  = "K099^Head MR^RSNA-Test";

 if ($modality eq "CT") {
  $us_id = "K199^Head CT^RSNA-Test^K199_A1^Head CT Protocol Item 1^RSNA-Test";
  $proc  = "K199^Head CT^RSNA-Test";
 } elsif ($modality eq "PT") {
  $us_id = "K299^Head PT^RSNA-Test^K299_A1^Head PT Protocol Item 1^RSNA-Test";
  $proc  = "K299^Head PT^RSNA-Test";
 }
 return ($us_id, $proc);
}
 

sub get_study_identifiers {
 my ($hl7_folder, $kos_path) = @_;
 my $accession_number   = xdsi::extract_one_field($kos_path, "0008,0050");
 my $modality           = xdsi::extract_one_field($kos_path, "0008,0060");
 my $study_instance_uid = xdsi::extract_one_field($kos_path, "0020,000D");

 my ($universal_service_id, $proc_code) = lookup_procedure($modality);

 my $identifiers = 
	"\$UNIVERSAL_SERVICE_ID\$ = $universal_service_id\n" .
	"\$RELEVANT_CLINICAL_INFO\$ = xxx\n" .
	"\$SPECIMEN_SOURCE\$ = Radiology^^^^R^\n" .
	"\$TRANSPORTATION_MODE\$ = WALK\n" .
	"\$TRANSPORT_ARRANGED\$ = A\n" .
	"\$DIAG_SERV_SECT\$ = $modality\n" .
	"\$PROCEDURE_CODE\$ = $proc_code\n".
	"\$ACCESSION_NUMBER\$ = $accession_number\n" .
	"\$REQUESTED_PROCEDURE_ID\$ = R-$accession_number\n" .
	"\$SCHEDULED_PROCEDURE_STEP_ID\$ = S-$accession_number\n" .
	"\$PLACER_ORDER_NUMBER\$ = P-$accession_number\n" .
	"\$FILLER_ORDER_NUMBER\$ = F-$accession_number\n" .
	"\$STUDY_INSTANCE_UID\$ = $study_instance_uid\n" ;

 return $identifiers;
}

sub process_study {
 my ($base) = @_;
 my $hl7_folder = "$base/hl7";
 mkdir $hl7_folder if (! -e $hl7_folder);
 my $kos_path = "$base/kos/kos.dcm";
 my $image_path = "$base/images/000000.dcm";
 my $demog_string = get_demographics($hl7_folder, $image_path);
 my $study_identifiers = get_study_identifiers($hl7_folder, $image_path);
 my $tmp_x = "/tmp/x.var";
 write_fixed_key_values($tmp_x);
 my $tmp_y = "/tmp/y.var";
 write_study_key_values($tmp_y, $demog_string, $study_identifiers);

 mesa_msgs::create_text_file_2_var_files(
	"$hl7_folder/orm.txt",		# This is the output
	"../common/ihe_sched.tpl",	# Template for an O01 message
	$tmp_x,				# Input file 1
	$tmp_y);			# Second input

 mesa_msgs::create_hl7("$hl7_folder/orm");
 print "Created: orm\n" if ($verbose);

 mesa_msgs::create_text_file_2_var_files(
	"$hl7_folder/oru.txt",		# This is the output
	"../common/ihe_oru.tpl",	# Template for an O01 message
	$tmp_x,				# Input file 1
	$tmp_y);			# Second input

 mesa_msgs::create_hl7("$hl7_folder/oru");
 print "Created: oru\n" if ($verbose);
}

sub process_patient {
 my ($base, $patient) = @_;
 my @study_folders = xdsi::read_folder("$base/$patient");
 foreach $s(@study_folders) {
  process_study("$base/$patient/$s");
 }
}

 die "Usage: extension [verbose]\n" if (scalar(@ARGV) < 1);

 $verbose = 0;
 $verbose = 1 if (scalar(@ARGV) > 1);
 $extension = $ARGV[0];

 my $base = "/opt/xdsi/storage/isn-phr/$extension";
 my @patient_folders = xdsi::read_folder($base);
 foreach $p(@patient_folders) {
  print "$p\n";
  process_patient($base, $p);
 }

