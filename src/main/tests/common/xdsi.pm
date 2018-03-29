# General package for XDSI testing

use Env;

package xdsi;

require Exporter;
@ISA=qw(Exporter);

sub check_environment {
 die "XDSI variable not defined" if !(defined $main::XDSI);
 die "XDSI variable not defined" if $main::XDSI eq "";
 $java_home="/opt/xdsi/java/jdk1.8.0_65";
 die "JAVA home folder not found: $java_home" if (! -e $java_home);

 $java_executable="$java_home/bin/java";

}

sub ini_exists {
 my ($ids_name) = @_;
 my $x = "$main::XDSI/runDirectory/$ids_name.ini";
 die ".ini file for $ids_name does not exist" if (! -e $x);
}

sub generate_identifier {
 my ($identifier_type) = @_;
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.util.Identifiers $identifier_type";
  my $y = `$x`; chomp $y;
  return $y;
}

# Subroutine generates a new local patient identifier

sub generate_identifier_local {
  return generate_identifier("DEPARTMENT");
}

# Subroutine generates a new patient identifier in the Affinity Domain

sub generate_identifier_affinity_domain {
  return generate_identifier("AFFINITYDOMAIN");
}

sub generate_study_uid {
  return generate_identifier("STUDY_UID");
}

sub generate_accession_number() {
  return generate_identifier("ACCESSION");
}

sub generate_new_image_set {
 my ($output_folder, $input_folder, $patient_id, $study_uid, $accession_number) = @_;
 print "generate_new_image_set $input_folder $output_folder\n";
 print "UID: $study_uid Accession Number $accession_number\n";
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility " .
	"REIDENTIFY $output_folder $input_folder $patient_id $study_uid $accession_number";
 print "$x\n";
 print `$x`;
 
}

sub generate_new_image_set_full {
 my ($output_folder, $input_folder, $patient_id, $study_uid, $accession_number, $name, $dob, $sex, $study_date) = @_;
 print "generate_new_image_set $input_folder $output_folder\n";
 print "UID: $study_uid Accession Number $accession_number\n";
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility " .
	"REIDENTIFY_FULL $output_folder $input_folder $patient_id $study_uid $accession_number $name $dob $sex $study_date";
 print "$x\n";
 print `$x`;
 
}

sub generate_kos {
 my $argument_count = scalar(@_);
 die "Wrong argment count to xdsi::generate_kos $argument_count / 6" if ($argument_count != 6);
 my ($input_folder, $output_folder, $file_name, $ae_title, $ad_id, $retrieve_location_uid) = @_;
 print "generate_kos $input_folder $output_folder $file_name\n";
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility " .
	"MAKEKOS $input_folder $output_folder $file_name $ae_title $ad_id $retrieve_location_uid";
 print "$x\n";
 print `$x`;
}

sub generate_rad69_data {
 my $argument_count = scalar(@_);
 die "Wrong argment count to xdsi::generate_rad69_data $argument_count / 4" if ($argument_count != 4);
 my ($path_full, $path_study_xfer, $path_kos, $repository_unique_id) = @_;
 print "generate_rad69_data $path_full $path_study_xfer $path_kos $repository_unique_id\n";
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility " .
	"KOS-TO-RAD69 $path_kos $repository_unique_id $path_full $path_study_xfer";
 print "$x\n";
 print `$x`;
}

sub send_RAD4 {
 my ($config_system_under_test, $identifier_local, $uid_study, $accession_number) = @_;
 print "send_RAD4\n" .
	" Configuration file: $config_system_under_test\n" .
	" Patient ID:         $identifier_local\n" .
	" Study UID:          $uid_study\n" .
	" Accession Number:   $accession_number\n";
}

sub send_CSTORE {
 my ($config_system_under_test, $folder) = @_;
 print "send_CSTORE\n" .
	" Configuration file: $config_system_under_test\n" .
	" Folder:             $folder\n" ;
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "java -cp $jar edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility " .
	"SENDIMAGES $config_system_under_test $folder";
 print "$x\n";
 print `$x`;
}

sub exist_or_die_folder {
 my ($folder, $txt) = @_;
 die "Folder does not exist: $folder, from $txt" if (! -d $folder);
}

sub validate_rad16 {
 die "validate_rad16 requires 8 arguments\n" if (scalar(@_) != 8);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $extension, $label, $test_name, $options) = @_;

 print "validate_rad16\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
 my @levels = split(/:/, $options);
 foreach $level(@levels) {
  print "Level: $level\n";
  my $std_folder = "$main::XDSI/storage/ids/$extension/$pid_dept/images";
  my $tst_folder = "$main::XDSI/results/$label/$test_name/RAD-16/$level";
  exist_or_die_folder($std_folder, "xdsi::validate_rad16");
  exist_or_die_folder($tst_folder, "xdsi::validate_rad16");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestDcmSetContent" .
	" RUNTEST $tst_folder $std_folder $label $extension $test_name $level";
#	"TESTLOGS2 $sim_name $pid_dept $pid_affinity_domain $label $extension $test_name";

  print "$x\n";
  print `$x`;
 }
}

sub validate_rad16_multi {
 die "validate_rad16_multi requires 8 arguments\n" if (scalar(@_) != 8);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $extension, $label, $test_name, $options) = @_;

 print "validate_rad16_multi\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
  my $std_folder = "$main::XDSI/storage/ids/$extension/$pid_dept/images";
  my $tst_folder = "$main::XDSI/results/$label/$test_name/RAD-16";
  exist_or_die_folder($std_folder, "xdsi::validate_rad16");
  exist_or_die_folder($tst_folder, "xdsi::validate_rad16");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestDcmSetContent" .
	" RUNMULTILEVEL $tst_folder $std_folder $label $extension $test_name $options";

  print "$x\n";
  print `$x`;
}

sub validate_rad69_single {
 die "validate_rad69_single requires 7 arguments\n" if (scalar(@_) != 7);

 my ($pid_dept, $pid_affinity_domain, $ids_name, $extension, $label, $test_name, $options) = @_;

 print "validate_rad69_single\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" IDS Name:            $ids_name\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
  my $std_folder = "$main::XDSI/storage/ids/$extension/$pid_dept/images";
  my $tst_folder = "$main::XDSI/results/$label/$test_name/RAD-69/attachments";
  exist_or_die_folder($std_folder, "xdsi::validate_rad69_single");
  exist_or_die_folder($tst_folder, "xdsi::validate_rad69_single");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestDcmSetContent" .
	" RUNSINGLELEVEL $tst_folder $std_folder $label $extension $test_name";

  print "$x\n";
  print `$x`;
}

sub validate_rad69_xc {
 die "validate_rad69_xc  requires 9 arguments\n" if (scalar(@_) != 9);

 my ($pid_dept, $communityA, $communityB, $communityC, $iig_name, $extension, $label, $test_name, $options) = @_;
 print "validate_rad69_xc \n" .
	" PID Department:      $pid_dept\n" .
	" Communities:         $communityA $communityB $communityC\n" .
	" IIG Name:            $iig_name\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";

 my $communityLabel = "";
 if ($communityA == 1)      { $communityLabel = "A"; }
 elsif ($communityB == 1) { $communityLabel = "B"; }
 elsif ($communityC == 1) { $communityLabel = "C";}
 else { die "All communityX flags set to 0\n";}

  my $std_folder = "$main::XDSI/storage/iig/$extension-$communityLabel/$pid_dept/images";
  my $tst_folder = "$main::XDSI/results/$label/$test_name/RAD-69";
  exist_or_die_folder($std_folder, "xdsi::validate_rad69_xc standard images");
  exist_or_die_folder($tst_folder, "xdsi::validate_rad69_sc images to be tested");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.iig.TestRAD69" .
	" iig-1001 $tst_folder $std_folder ";

  print "$x\n";
  die "validate_rad69_xc $x\n";
  print `$x`;
}

sub validate_rad69_exception {
 die "validate_rad69_exception requires 7 arguments\n" if (scalar(@_) != 7);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $extension, $label, $test_name) = @_;

 print "validate_rad69_exception\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
  my $tst_folder = "$main::XDSI/results/$label/$test_name/RAD-69";
  exist_or_die_folder($tst_folder, "xdsi::validate_rad69_exception");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestRAD69Exception" .
	" RUNTEST $tst_folder $label $extension $test_name SUBLABEL";

  print "$x\n";
  print `$x`;
}

sub validate_rad55_baseline {
 my ($pid_dept, $pid_affinity_domain, $wado_rul) = @_;
 print "validate_rad55_one_study\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" WADO URL:            $wado_url\n";
 my $std_folder = "$main::XDSI/storage/runtime/$pid_dept/images";
 my $tst_folder = "$main::XDSI/storage/runtime/$pid_dept/RAD-55/baseline";
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestDcmSetContent" .
	" RUNTEST $tst_folder $std_folder";
 print "$x\n";
 print `$x`;
}

sub validate_rad55_multi {
 die "validate_rad55_multi requires 7 arguments\n" if (scalar(@_) != 7);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $extension, $label, $test_name) = @_;

 print "validate_rad55_multi\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
  my $std_folder = "$main::XDSI/storage/ids/$extension/$pid_dept/images";
  my $tst_folder = "$main::XDSI/results/$label/$test_name/RAD-55/attachments";
  exist_or_die_folder($std_folder, "xdsi::validate_rad55_multi");
  exist_or_die_folder($tst_folder, "xdsi::validate_rad55_multi");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestDcmSetContent" .
	" RUNSINGLELEVEL $tst_folder $std_folder $label $extension $test_name";

  print "$x\n";
  print `$x`;
}

sub validate_rad55_exception {
 die "validate_rad55_exception requires 7 arguments\n" if (scalar(@_) != 7);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $extension, $label, $test_name) = @_;

 print "validate_rad55_exception\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
  my $tst_folder = "$main::XDSI/results/$label/$test_name/RAD-55";
  exist_or_die_folder($tst_folder, "xdsi::validate_rad55_exception");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestRAD55Exception" .
	" RUNTEST $tst_folder $label $extension $test_name SUBLABEL";

  print "$x\n";
  print `$x`;
}


sub validate_rad68 {
 my ($sim_name, $pid_dept, $pid_affinity_domain) = @_;
 print "validate_rad68\n" .
	" Simulator:           $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" ;
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestRAD68ImagingDocumentSource " .
	"TESTLOGS $sim_name $pid_dept $pid_affinity_domain";
 print "$x\n";
 print `$x`;
}

sub validate_rad68_v2 {
 my ($sim_name, $pid_dept, $pid_affinity_domain, $label, $extension, $test_name) = @_;
 print "validate_rad68_v2\n" .
	" Simulator:           $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" Label:               $label\n" .
	" Extension:           $extension\n" .
	" Test Name:           $test_name\n";

 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestRAD68ImagingDocumentSource " .
	"TESTLOGS2 $sim_name $pid_dept $pid_affinity_domain $label $extension $test_name";
 print "$x\n";
 print `$x`;
}

sub validate_rad68_dry_run {
 my ($sim_name, $pid_dept, $pid_affinity_domain) = @_;
 print "validate_rad68\n" .
	" Simulator:           $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" ;
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestRAD68ImagingDocumentSource " .
	"DRYRUN $sim_name $pid_dept $pid_affinity_domain";
 print "$x\n";
 print `$x`;
}

sub validate_rad68_dry_run_v2 {
 my ($sim_name, $pid_dept, $pid_affinity_domain, $label, $extension, $test_name) = @_;
 print "validate_rad68_v2\n" .
	" Simulator:           $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" Label:               $label\n" .
	" Extension:           $extension\n" .
	" Test Name:           $test_name\n";

 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestRAD68ImagingDocumentSource " .
	"DRYRUN2 $sim_name $pid_dept $pid_affinity_domain $label $extension $test_name";
 print "$x\n";
 print `$x`;
}

sub validate_ids_all_transactions {
 die "validate_ids_all_transactions requires 8 arguments\n" if (scalar(@_) != 8);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $extension, $label, $test_name, $options) = @_;

 print "validate_ids_all_transactions\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
  my $std_folder = "$main::XDSI/storage/ids/$extension/$pid_dept/images";
  my $tst_folder = "$main::XDSI/results/$label/$test_name";
  exist_or_die_folder($std_folder, "xdsi::validate_rad16");
  exist_or_die_folder($tst_folder, "xdsi::validate_rad16");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.TestIDSAllTransactions" .
	" RUNMULTILEVEL $tst_folder $std_folder $label $extension $test_name $options";

  print "$x\n";
  print `$x`;
}

sub validate_iig_xc_retrieve {
 die "validate_iig_xc_retrieve requires 4 arguments\n" if (scalar(@_) != 4);

 my ($iig_name, $label, $session, $test_name) = @_;
 print "validate_iig_xc_retrieve \n" .
	" IIG Name:            $iig_name\n" .
	" Label:               $label\n" .
	" Session:             $session\n" .
	" Test Name:           $test_name\n";

  my $tst_folder = "results/$label/$test_name";
  my $std_folder = "std/iig/$test_name";
  exist_or_die_folder("$main::XDSI/$std_folder", "xdsi::validate_iig_xc_retrieve standard images");
  exist_or_die_folder("$main::XDSI/$tst_folder", "xdsi::validate_iig_xc_retrieve images to be tested");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.iig.TestIIG" .
	" $test_name $session $tst_folder $std_folder ";

  print "$x\n";
  print `$x`;
}

sub validate_rig_xc_retrieve {
 die "validate_rig_xc_retrieve requires 4 arguments\n" if (scalar(@_) != 4);

 my ($iig_name, $label, $session, $test_name) = @_;
 print "validate_rig_xc_retrieve \n" .
	" RIG Name:            $rig_name\n" .
	" Label:               $label\n" .
	" Session:             $session\n" .
	" Test Name:           $test_name\n";

  my $tst_folder = "results/$label/$test_name";
  my $std_folder = "std/rig/$test_name";
  exist_or_die_folder("$main::XDSI/$std_folder", "xdsi::validate_rig_xc_retrieve standard images");
  exist_or_die_folder("$main::XDSI/$tst_folder", "xdsi::validate_rig_xc_retrieve images to be tested");
  my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
  my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.validation.rig.TestRIG" .
	" $test_name $session $tst_folder $std_folder ";

  print "$x\n";
  print `$x`;
}

sub rad16_sequence {
 die "rad16_sequence requires 8 arguments\n" if (scalar(@_) != 8);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $extension, $label, $test_name, $options) = @_;
 print "rad16_sequence\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS        = "$main::XDSI/storage/ids/$extension/$pid_dept/kos/kos.dcm";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-16";
 my $pathStorageSCP = "$main::XDSI/storage/storageSCP/$pid_dept";

 my $targetAE = "SIMSTORAGESCP";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.execution.RAD16Sequences " .
	"C-MOVE_KOS $pathOutput $pathKOS $moveSCPName $targetAE $options $pathStorageSCP";
 print "$x\n";
 print `$x`;
}

sub rad16_sequence_idc {
 my ($pid_dept, $pid_affinity_domain, $sim_name, $moveSCPName, $options) = @_;
 print "rad16_sequence\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" CMove Name:          $moveSCPName\n" .
	" Options:             $options\n";
 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS        = "/opt/xdsi/storage/idc/$pid_dept/kos/kos.dcm";
 my $pathOutput     = "/opt/xdsi/storage/idc/$pid_dept/RAD-16";
 my $pathStorageSCP = "/opt/xdsi/storage/storageSCP/$pid_dept";

 my $targetAE = "SIMSTORAGESCP";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.execution.RAD16Sequences " .
	"C-MOVE_KOS $pathOutput $pathKOS $moveSCPName $targetAE $options $pathStorageSCP";
 print "$x\n";
 print `$x`;
}

sub rad55_baseline{
 my ($pid_dept, $pid_affinity_domain, $sim_name, $wado_url) = @_;
 print "rad55_one_study\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" WADO URL:            $wado_url\n";
 my $jar = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS = "/opt/xdsi/storage/runtime/$pid_dept/kos/kos.dcm";
 my $pathOutput = "/opt/xdsi/storage/runtime/$pid_dept/RAD-55/baseline";
 my $content_type = "application/dicom";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.execution.RAD55Sequences " .
	"STUDY $pathKOS $pathOutput $wado_url $content_type";
 print "$x\n";
 print `$x`;
}

sub rad55_baseline_idc {
 my ($pid_dept, $pid_affinity_domain, $sim_name, $wado_url) = @_;
 print "rad55_one_study\n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" WADO URL:            $wado_url\n";
 my $jar          = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS      = "/opt/xdsi/storage/idc/$pid_dept/kos/kos.dcm";
 my $pathOutput   = "/opt/xdsi/storage/idc/$pid_dept/RAD-55/baseline";
 my $content_type = "application/dicom";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.execution.RAD55Sequences " .
	"STUDY $pathKOS $pathOutput $wado_url $content_type";
 print "$x\n";
 print `$x`;
}

sub rad55_multi {
 die "rad55_multi  requires 8 arguments\n" if (scalar(@_) != 8);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $ids_name, $extension, $label, $test_name, $options) = @_;
 print "rad55_multi \n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" IDS Name:            $ids_name\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS        = "$main::XDSI/storage/ids/$extension/$pid_dept/kos/kos.dcm";
 my $pathSingle     = "$main::XDSI/storage/ids/$extension/$pid_dept/images/000000.dcm";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-55";
# my $repositoryID   = "1.1.4567332.10.99";
# my $retrieveURL    = "http://localhost:9280/xdstools2/sim/xdsi01__img-doc-src/ids/ret.ids";

#  my ($study_uid, $series_uid, $instance_uid, $xfer_syntax) = extract_uids($pathSingle);
#  my $composite = "$study_uid:$series_uid:$instance_uid";
#  my $wado_url = " http://localhost:8080/wado";

 my $content_type = "application/dicom";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.execution.RAD55Sequences " .
	"STUDY $pathKOS $pathOutput $ids_name $content_type";
# my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.execution.RAD55Sequences " .
#	"STUDY $pathKOS $pathOutput $wado_url $content_type";
# my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
#	"SINGLE $pathOutput $retrieveURL $repositoryID \"\" $composite";
 print "$x\n";
 print `$x`;
}

sub rad55_single_exception {
 die "rad55_exception  requires 9 arguments\n" if (scalar(@_) != 9);

 my ($pid_dept, $pid_affinity_domain, $sim_name, $ids_name, $extension, $label, $test_name, $sub_label, $options) = @_;
 print "rad55_multi \n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" IDS Name:            $ids_name\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
# my $pathKOS        = "$main::XDSI/storage/ids/$extension/$pid_dept/kos/kos.dcm";
# my $pathSingle     = "$main::XDSI/storage/ids/$extension/$pid_dept/images/000000.dcm";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-55/$sub_label";
# my $repositoryID   = "1.1.4567332.10.99";
# my $retrieveURL    = "http://localhost:9280/xdstools2/sim/xdsi01__img-doc-src/ids/ret.ids";

#  my ($study_uid, $series_uid, $instance_uid, $xfer_syntax) = extract_uids($pathSingle);
#  my $composite = "$study_uid:$series_uid:$instance_uid";
#  my $wado_url = " http://localhost:8080/wado";

 my $content_type = "application/dicom";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.execution.RAD55Sequences " .
	"SINGLE $pathOutput $ids_name $options $content_type";
 print "$x\n";
 print `$x`;
}

sub rad69_single {
 die "rad69_single  requires 7 arguments\n" if (scalar(@_) != 7);

 my ($pid_dept, $pid_affinity_domain, $ids_name, $extension, $label, $test_name, $options) = @_;
 print "rad69_single \n" .
	" IDS Name:            $ids_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS        = "$main::XDSI/storage/ids/$extension/$pid_dept/kos/kos.dcm";
 my $pathSingle     = "$main::XDSI/storage/ids/$extension/$pid_dept/images/000000.dcm";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-69";
 my $repositoryID   = "1.1.4567332.10.99";
 my $retrieveURL    = "http://localhost:9280/xdstools2/sim/xdsi01__img-doc-src/ids/ret.ids";

  my ($study_uid, $series_uid, $instance_uid, $xfer_syntax) = extract_uids($pathSingle);
  my $composite = "$study_uid:$series_uid:$instance_uid";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
	"SINGLE $pathOutput $ids_name \"\" $composite";
 print "$x\n";
 print `$x`;
}

sub rad69_kos {
 die "rad69_kos  requires 7 arguments\n" if (scalar(@_) != 7);

 my ($pid_dept, $pid_affinity_domain, $ids_name, $extension, $label, $test_name, $options) = @_;
 print "rad69_kos \n" .
	" XDS Reg/Rep Simulator: $sim_name\n" .
	" PID Department:      $pid_dept\n" .
	" PID Affinity Domain: $pid_affinity_domain\n" .
	" IDS Name:            $ids_name\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";
 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS        = "$main::XDSI/storage/ids/$extension/$pid_dept/kos/kos.dcm";
 my $pathSingle     = "$main::XDSI/storage/ids/$extension/$pid_dept/images/000000.dcm";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-69";
# my $repositoryID   = "1.1.4567332.10.99";
 my $retrieveURL    = "http://localhost:9280/xdstools2/sim/xdsi01__img-doc-src/ids/ret.ids";

  my ($study_uid, $series_uid, $instance_uid, $xfer_syntax) = extract_uids($pathSingle);
  my $composite = "$study_uid:$series_uid:$instance_uid";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
	"KOS $pathOutput $ids_name \"\" $pathKOS";
 print "$x\n";
 print `$x`;
}

sub rad69_xc_kos {
 die "rad69_xc_kos  requires 9 arguments\n" if (scalar(@_) != 9);

 my ($pid_dept, $communityA, $communityB, $communityC, $iig_name, $extension, $label, $test_name, $options) = @_;
 print "rad69_xc_kos \n" .
	" PID Department:      $pid_dept\n" .
	" Communities:         $communityA $communityB $communityC\n" .
	" IIG Name:            $iig_name\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";

 my $communityLabel = "";
 if ($communityA == 1)      { $communityLabel = "A"; }
 elsif ($communityB == 1) { $communityLabel = "B"; }
 elsif ($communityC == 1) { $communityLabel = "C";}
 else { die "All communityX flags set to 0\n";}

 my $ids_name = "no-ids";

 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathKOS        = "$main::XDSI/storage/iig/$extension-$communityLabel/$pid_dept/kos/kos.dcm";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-69";

  die "KOS file not found at $pathKOS\n" if (! -e $pathKOS);


 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
	"KOS_XC $pathOutput $ids_name $iig_name \"\" $pathKOS";
 print "$x\n";
# print `$x`;
}

sub rad69_xc_single {
 die "rad69_xc_single  requires 10 arguments\n" if (scalar(@_) != 10);

 my ($pid_dept, $communityA, $communityB, $communityC, $ids_name, $iig_name, $extension, $label, $test_name, $options) = @_;
 print "rad69_xc_single \n" .
	" PID Department:      $pid_dept\n" .
	" Communities:         $communityA $communityB $communityC\n" .
	" IDS Name:            $ids_name\n" .
	" IIG Name:            $iig_name\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n" .
	" Options:             $options\n";

 my $communityLabel = "";
 if ($communityA == 1)      { $communityLabel = "A"; }
 elsif ($communityB == 1) { $communityLabel = "B"; }
 elsif ($communityC == 1) { $communityLabel = "C";}
 else { die "All communityX flags set to 0\n";}

 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathSingle     = "$main::XDSI/storage/iig/$extension-$communityLabel/$pid_dept/images/000000.dcm";
# my $pathImage    = "1.3.6.1.4.1.21367.201599.1.201602100826053" .
#                    ":1.3.6.1.4.1.21367.201599.2.201602100826053" . 
#                    ":1.3.6.1.4.1.21367.201599.3.201602100826053.15";
 my ($study_uid, $series_uid, $instance_uid, $xfer_syntax) = extract_uids($pathSingle);
 my $composite = "$study_uid:$series_uid:$instance_uid";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-69";

#  die "Image file not found at $pathImage\n" if (! -e $pathImage);


# my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
#	"SINGLE_XC $pathOutput $ids_name $iig_name \"\" $pathImage";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
	"SINGLE_XC $pathOutput $ids_name $iig_name \"\" $composite";
 print "$x\n";
 print `$x`;
}

sub rad69_xc_multi {
 die "rad69_xc_multi  requires 6 arguments\n" if (scalar(@_) != 6);

 my ($ids_name, $iig_name, $transfer_syntax_path, $uid_path, $label, $test_name) = @_;
 print "rad69_xc_single \n" .
	" IDS Name:            $ids_name\n" .
	" IIG Name:            $iig_name\n" .
	" Xfer Syntax:         $transfer_syntax_path\n" .
	" UID Path:            $uid_path\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n";

 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";

 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-69";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
	"MULTI_XC $pathOutput $ids_name $iig_name $transfer_syntax_path $uid_path";
 print "$x\n";
 print `$x`;
}


sub rad69_single_exception {
 die "rad69_single_exception  requires 7 arguments\n" if (scalar(@_) != 7);

 my ($extension, $label, $test_name, $sub_label, $uids, $ids_name, $xfer_path) = @_;
 print "rad69_exception \n" .
	" Extension:           $extension\n" .
	" Label:               $label\n" .
	" Sub Label            $sub_label\n" .
	" Test Name:           $test_name\n" .
	" UIDs:                $uids\n" .
	" Repository ID:       $repos_id\n" .
	" Xfer syntax path:    $xfer_path\n" ;

 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-69/$sub_label";
# my $retrieveURL    = "http://localhost:9280/xdstools2/sim/xdsi01__img-doc-src/ids/ret.ids";

# my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
#	"SINGLE $pathOutput $retrieveURL $repos_id $xfer_path $uids";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_69_IDC " .
	"SINGLE $pathOutput $ids_name \"\" $uids";
 print "$x\n";
 print `$x`;
}

sub rad75_get_soap {
 my ($rig_simulator_name, $iig_name, $label, $test_name) = @_;
 print "rad75_get_soap \n".
	"IDS        $ids_name\n" .
	"IIG        $iig_name\n" .
	"Label      $label\n" .
	"Test Name  $test_name\n";

 my $arg1 = $rig_simulator_name;
 my $arg2 = "rg";
 my $arg3 = "xcr.ids";
 my $arg4 = "-";
 my $arg5 = "results/$label/$test_name/RAD-75";

 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";
 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.util.ProcessNISTSimulatorLogs " .
	"GETSOAP $arg1 $arg2 $arg3 $arg4 $arg5";
 print "$x\n";
 print `$x`;
}


sub rad75_xc_multi {
 die "rad75_xc_multi  requires 5 arguments\n" if (scalar(@_) != 5);

 my ($rig_name, $transfer_syntax_path, $uid_path, $label, $test_name) = @_;
 print "rad75_xc_single \n" .
	" RIG Name:            $rig_name\n" .
	" Xfer Syntax:         $transfer_syntax_path\n" .
	" UID Path:            $uid_path\n" .
	" Label:               $label\n" .
	" Test Name:           $test_name\n";

 my $jar            = "$main::XDSI/lib/ERL-IHE-XDSI.jar";

 my $pathOutput     = "$main::XDSI/results/$label/$test_name/RAD-75";

 my $x = "$java_executable -cp $jar edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_75_IIG " .
	"MULTI $pathOutput $rig_name $transfer_syntax_path $uid_path";
 print "$x\n";
 print `$x`;
}

sub read_folder {
  my ($folder) = (@_);
  opendir (my $dh, $folder) or die "Could not open folder: $folder";
  @entries = grep { !/^\./ && -d "$folder/$_" } readdir($dh);
  close $dh;
  return @entries;
}

sub read_folder_recursive {
  my ($path) = (@_);
  @xdsi::leaf_nodes;
  traverse($path);
  return @xdsi::leaf_nodes;
}

sub traverse {
  my ($path) = (@_);
  if (-f $path) {
    push (@xdsi::leaf_nodes, $path);
  } else {
    opendir (my $dh, $path) or die "Could not open folder: $path";
    while (my $f = readdir $dh) {
      next if ($f eq "." or $f eq "..");
      traverse("$path/$f");
    }
    close $dh;
  }
}

sub extract_field {
 my ($s, $index) = (@_);
 my @tokens = split(" ", $s);
 my $x = $tokens[$index];
 my $len = length $x;
 my $y = substr($x, 1, $len-2);
 return $y;
}

sub extract_one_field {
 my ($path, $field) = @_;
  my $tmp = "/tmp/x.txt";
  my $x = "dcmdump $path > $tmp";
  print `$x`;
  die "Could not execute $x" if $?;
  my $x1 = "grep -i '$field' $tmp";
  my $x1a = `$x1`;
  my $x1b = extract_field($x1a, 4);
  return $x1b;
}

sub extract_uids {
  my ($path) = (@_);
  my $xfer_syntax = extract_one_field($path, "0002,0010");
  my $study_uid = extract_one_field($path, "0020,000D");
  my $series_uid = extract_one_field($path, "0020,000E");
  my $instance_uid = extract_one_field($path, "0008,0018");
  return ($study_uid, $series_uid, $instance_uid, $xfer_syntax);
}

sub extract_uids_from_collection {
  my %h = ();
  foreach $path(@_) {
    my ($study_uid, $series_uid, $instance_uid, $xfer_syntax) = xdsi::extract_uids($path);
    my $composite = $study_uid . ":" . $series_uid . ":" . $instance_uid;
    $h{$composite} = 1;
  }
  return keys %h;
}

;
