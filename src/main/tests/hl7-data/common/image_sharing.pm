use Env;

package image_sharing;

require Exporter;
@ISA = qw(Exporter);

# We do not wish to export any subroutines.
@EXPORT = qw(
);

sub check_environment {
 @ folders = ( "scripts", "db");
 foreach $f(@folders) {
  if (!(-e $f)) { die "Are you in the proper folder: did not find <$f>"; }
 }

 if (! $main::MESA_TARGET) { die "MESA_TARGET undefined"; }

 if (! (-e "$MESA_TARGET/bin")) { die "Is MESA properly installed in $MESA_TARGET? Missing bin folder."; }

 if (! $main::DCM4CHE_HOME) { die "DCM4CHE_HOME undefined"; }

 if (! (-e "$DCM4CHE_HOME/bin")) { die "Is DCM4CHE properly installed in $DCM4CHE_HOME? Missing bin folder."; }

}

sub compute_file_lengths {
 my $folderName = shift;

 @allFiles = <$folderName/*>;

 $total = 0;
 foreach $f(@allFiles) {
  $fileSize = -s "$f";
#  print "$f $fileSize\n";
  $total += $fileSize;
 }
 return $total;
}

sub generate_date_time {
  ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
  $year += 1900; $mon++;
  $mon  = "0" . $mon  if ($mon  < 10);
  $mday = "0" . $mday if ($mday < 10);
  $hour = "0" . $hour if ($hour < 10);
  $min  = "0" . $min  if ($min  < 10);
  $sec  = "0" . $sec  if ($sec  < 10);

#  my $t = $year . $mon . $mday . $hour . $min . $sec;
  my $t = $year . $mon . $mday . $hour . $min;
  return $t;
}

sub generate_date_time_with_delta {
  my ($hourDelta) = @_;
  ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
  $hour -= $hourDelta;
  if ($hour < 0) {
    $hour += 24;
    $mday--;
  }
  if ($mday < 1) {
    $mday = 27;
    $mon--;
  }
  if ($mon < 1) {
   $mon += 12;
   $year --;
  }
  if ($mday < 1) {
    $mday = 27;
    $mon--;
  }
  if ($mon < 1) {
   $mon += 12;
   $year --;
  }

  $year += 1900; $mon++;
  $mon  = "0" . $mon  if ($mon  < 10);
  $mday = "0" . $mday if ($mday < 10);
  $hour = "0" . $hour if ($hour < 10);
  $min  = "0" . $min  if ($min  < 10);
  $sec  = "0" . $sec  if ($sec  < 10);

#  my $t = $year . $mon . $mday . $hour . $min . $sec;
  my $t = $year . $mon . $mday . $hour . $min;
  return $t;
}

sub remove_folder {
 my $folder = shift;

 if (-e $folder) {
  $x = "rm -r $folder";
  `$x`;
  die "Could not remove folder: $folder" if $?;
 }
}

sub construct_hl7_orm_or_oru {
 my $output = shift;
 my $template = shift;
 my $standardFields = shift;

 my %h = @_;

 $name = $h{"NAME"};
 $patientID = $h{"PATID"};
 $accessionNumber = $h{"ACCESSION_NUMBER"};

 my $tmpFile = "/tmp/hl7_var.txt";
 open TMP, ">$tmpFile"       or die "Could not open temporary file: $tmpFile";
 open STD, "<$standardFields" or die "Could not open standard fields: $standardFields";

 while ($k = <STD>) {
  print TMP "$k";
 }
 print TMP "\$PATIENT_ID\$ = $patientID\n";
 print TMP "\$PATIENT_NAME\$ = $name\n";
 print TMP "\$SEX\$ = $h{'SEX'}\n";
 print TMP "\$DATE_TIME_BIRTH\$ = $h{'DATE_TIME_BIRTH'}\n";
 print TMP "\$PATIENT_ADDRESS\$ = $h{'PATIENT_ADDRESS'}\n";
 print TMP "\$PATIENT_ACCOUNT_NUM\$ = $h{'PATIENT_ID'}\n";
 print TMP "\$PLACER_ORDER_NUMBER\$ = $h{'PLACER_ORDER_NUMBER'}\n";
 print TMP "\$FILLER_ORDER_NUMBER\$ = $h{'FILLER_ORDER_NUMBER'}\n";
 print TMP "\$ACCESSION_NUMBER\$ = $h{'ACCESSION_NUMBER'}\n";
 print TMP "\$VISIT_NUMBER\$ = $h{'VISIT_NUMBER'}\n";
 print TMP "\$DATE_TIME\$ = $h{'DATE_TIME'}\n";
 print TMP "\$STUDY_INSTANCE_UID\$ = 1.2.3.4." . $h{'DATE_TIME'} . "\n";
 print TMP "\$ORDER_EFFECTIVE_DATE\$ = $h{'DATE_TIME'}\n";
 print TMP "\$REQUESTED_PROCEDURE_ID\$ = $h{'REQUESTED_PROCEDURE_ID'}\n";
 print TMP "\$SCHEDULED_PROCEDURE_STEP_ID\$ = $h{'SCHEDULED_PROCEDURE_STEP_ID'}\n";
 print TMP "\$Z\$ = $h{'Z'}\n";
 print TMP "\$Z\$ = $h{'Z'}\n";
 close STD;

 my $tmpTwo = "/tmp/hl7_orm.txt";
 my $x = "perl $main::MESA_TARGET/bin/tpl_to_txt.pl $tmpFile $template $tmpTwo";

 my $y = "$main::MESA_TARGET/bin/txt_to_hl7 -d ihe -b $main::MESA_TARGET/runtime < $tmpTwo > $output";

 `$x`;
 die "Could not execute: $x" if $?;

 `$y`;
 die "Could not execute: $y" if $?;
}

sub xmit_hl7 {
  my $hostName = $_[0];
  my $port = $_[1];

  my $maxIndex = scalar(@_);
  my $idx = 2;
  for ($idx = 2; $idx < $maxIndex; $idx++) {
    my $x = "$main::MESA_TARGET/bin/send_hl7 localhost 20000 $_[$idx]";
    `$x`;
    die "Could not execute: $x" if $?;
  }
}

# # #
# DICOM functions
# # #

sub default_DICOM_params {
 return("RSNA-ISN", "localhost", 4104);
}

sub extract_DICOM_attributes {
  my $path = shift;

  my %attributeHash;
  @tags = ("0002 0010", "0008 0018", "0008 0050", "0010 0010", "0010 0020", "0020 000D", "0020 000E");
  foreach $t(@tags) {
    my $x = "/opt/mesa/bin/dcm_print_element $t $path";
    my $y = `$x`; chomp $y;
    $attributeHash{$t} = $y;
  }
  return %attributeHash;
}

sub check_dicom_rcvr
{
  my ($ae, $dcmHost, $port) = @_;

  my $x = "$main::DCM4CHE_HOME/bin/dcmecho $ae" . "@" . "$dcmHost:$port";
  `$x`;
  if ($?) {
    print "DICOM Connection failed: $x\n\n";
    print `$x`;
    die "\n\n";
  }
}

sub cstore
{
  my ($folder, $ae, $dcmHost, $port, $name, $patID, $accessionNumber, $uidPrefix) = @_;
  my $studyTime = "120000";
  my $x = "$main::DCM4CHE_HOME/bin/dcmsnd $ae" . "@" . "$dcmHost:$port $folder";
  $x .= " -ts1 ";
  $x .= " -set 00100010='$name'";
  $x .= " -set 00100020=$patID";
  $x .= " -set 00080050=$accessionNumber";
  $x .= " -set 00080030=$studyTime";
  $x .= " -set 00100021=ISSUER";
  $x .= " -setuid $uidPrefix" if ($uidPrefix ne "");

  `$x`;
  die "Could not execute $x" if $?;
}

sub cstore_EVRLE
{
  my ($folder, $ae, $dcmHost, $port, $name, $patID, $accessionNumber, $uidPrefix) = @_;
  my $studyTime = "120000";

  my $x = "/opt/mesa/bin/send_image -X 1.2.840.10008.1.2.1 -c $ae $dcmHost $port $folder";

  `$x`;
  die "Could not execute $x" if $?;
}


 
1;
