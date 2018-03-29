use Env qw(XDSI);
require xdsi;

# This script performs Rad-69 retrieve from an Imaging Document Source.

sub execute_ids_enhanced_ct {
 my($label, $extension, $rep_reg, $ids_name) = @_;
}
sub execute_ids_enhanced_mr {
 my($label, $extension, $rep_reg, $ids_name) = @_;
}
sub execute_ids_mammography {
 my($label, $extension, $rep_reg, $ids_name) = @_;
}
sub execute_ids_multi_image {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-multi-image/ids-multi-image-10.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
}
sub execute_ids_multimodality {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-multimodality/ids-multimodality-10.pl $label $extension $rep_reg $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-multimodality/ids-multimodality-11.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}
sub execute_ids_pet {
 my($label, $extension, $rep_reg, $ids_name) = @_;
}

sub execute_ids_rad16_multi {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-rad16-multi/ids-rad16-multi-10.pl $label $extension $rep_reg $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-rad16-multi/ids-rad16-multi-11.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}

sub execute_ids_rad16_single {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-rad16-single/ids-rad16-single-10.pl $label $extension $rep_reg $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-rad16-single/ids-rad16-single-11.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}

sub execute_ids_rad55_multi {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-rad55-multi/ids-rad55-multi-10.pl $label $extension $rep_reg $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-rad55-multi/ids-rad55-multi-11.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}

sub execute_ids_rad55_single {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-rad55-single/ids-rad55-single-10.pl $label $extension $rep_reg $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-rad55-single/ids-rad55-single-11.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}

sub execute_ids_rad69_exception {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-rad69-exception/ids-rad69-exception-10.pl $label $extension $rep_reg $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-rad69-exception/ids-rad69-exception-11.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}

sub execute_ids_rad69_multi {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-rad69-multi/ids-rad69-multi-10.pl $label $extension $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-rad69-multi/ids-rad69-multi-11.pl $label $extension $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}
sub execute_ids_rad69_single {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-rad69-single/ids-rad69-single-10.pl $label $extension $ids_name";
 my $y = "perl $XDSI/tests/ids/ids-rad69-single/ids-rad69-single-11.pl $label $extension $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
 print "$y\n";
 print `$y`; die "$y\n" if $?;
}
sub execute_ids_single_image {
 my($label, $extension, $rep_reg, $ids_name) = @_;
 my $x = "perl $XDSI/tests/ids/ids-single-image/ids-single-image-10.pl $label $extension $rep_reg $ids_name";
 print "$x\n";
 print `$x`; die "$x\n" if $?;
}
sub execute_ids_ultrasound {
 my($label, $extension, $rep_reg, $ids_name) = @_;
}
sub execute_ids_xra {
 my($label, $extension, $rep_reg, $ids_name) = @_;
}

xdsi::check_environment();

my $arg_count = scalar(@ARGV);
die "Arguments: label extension simulator-name ids_name\n" .
    "  label              Label for the Imaging Document source (no spaces)\n" .
    "  extension          Specifies test data set (a, b, c, ...) \n" .
    "  simulator-name     Name of the XDS.b Rep/Registry simulator (probably xxx_rep-reg)\n" .
    "  ids_name           Name of the IDS configuration (for a .ini file)\n"
 if ($arg_count != 4);


my $label     =  $ARGV[0];
my $extension =  $ARGV[1];
my $rep_reg    = $ARGV[2];
my $ids_name   = $ARGV[3];

print "Label:     $label\n";
print "Extension: $extension\n";
print "IDS Name:  $ids_name\n";

xdsi::ini_exists($ids_name);


execute_ids_single_image   ($label, $extension, $rep_reg, $ids_name);
execute_ids_multi_image    ($label, $extension, $rep_reg, $ids_name);
execute_ids_rad16_single   ($label, $extension, $rep_reg, $ids_name);
execute_ids_rad16_multi    ($label, $extension, $rep_reg, $ids_name);
execute_ids_rad55_single   ($label, $extension, $rep_reg, $ids_name);
execute_ids_rad55_multi    ($label, $extension, $rep_reg, $ids_name);
execute_ids_rad69_single   ($label, $extension, $rep_reg, $ids_name);
execute_ids_rad69_multi    ($label, $extension, $rep_reg, $ids_name);
execute_ids_rad69_exception($label, $extension, $rep_reg, $ids_name);
execute_ids_multimodality  ($label, $extension, $rep_reg, $ids_name);

#execute_ids_enhanced_ct    ($label, $extension, $rep_reg, $ids_name);
#execute_ids_enhanced_mr    ($label, $extension, $rep_reg, $ids_name);
#execute_ids_mammography    ($label, $extension, $rep_reg, $ids_name);
#execute_ids_pet            ($label, $extension, $rep_reg, $ids_name);
#execute_ids_ultrasound     ($label, $extension, $rep_reg, $ids_name);
#execute_ids_xra            ($label, $extension, $rep_reg, $ids_name);
