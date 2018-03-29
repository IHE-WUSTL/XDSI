use Env qw(XDSI);
use File::Copy;
use File::Path qw(make_path);
require xdsi;

sub read_folder {
  my ($folder) = (@_);
  opendir (my $dh, $folder) or die "Could not open folder: $folder";
  @entries = grep { !/^\./ && -d "$folder/$_" } readdir($dh);
  close $dh;
  return @entries;
}

sub read_images {
  my ($folder) = (@_);
  opendir (my $dh, "$folder") or die "Could not open images folder: $folder";
  @entries = grep { !/^\./ && -f "$folder/$_" } readdir($dh);
  close $dh;
  return @entries;
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
  my ($path) = (@_);
  my $tmp = "/tmp/x.txt";
  my $x = "dcmdump $path > $tmp";
  die "Could not execute $x" if `$x` != 0;
  my $x1 = "grep -i '$field' $tmp";
  my $x1a = `$x1`;
  my $x1b = extract_field($x1a, 4);
  return $x1b;
}


sub extract_uids {
  my ($path) = (@_);
  my $xfer_syntax = extract_one_field($path, "0002,0010");
  my $study_uid = extract_one_field($path,   ": (0020,000D");
  my $series_uid = extract_one_field($path,  "0020,000E");
  my $instance_uid = extract_one_field($path, "0008,0018");
  return ($study_uid, $series_uid, $instance_uid, $xfer_syntax);
}

sub compress_one_file{
  my ($output_folder, $output_xfer_syntax, $input_file) = @_;
  my $xformer = "/opt/xdsi/dcm4che/dcm4che-3.3.7/bin/dcm2dcm ";

  my $z = "$xformer -t $output_xfer_syntax $input_file $output_folder/$output_xfer_syntax > /dev/null";
  print "$z\n";
  die "Could not execute $z" if `$z` != 0;
}

sub compress_original {
  my ($output_folder, $xfer_syntax) = @_;

  compress_one_file($output_folder, "1.2.840.10008.1.2.4.70", "$output_folder/$xfer_syntax");
  compress_one_file($output_folder, "1.2.840.10008.1.2.4.80", "$output_folder/$xfer_syntax");
  compress_one_file($output_folder, "1.2.840.10008.1.2.4.90", "$output_folder/$xfer_syntax");
}

sub process_folder {
  my ($input_folder, $target_folder) = @_;
  mkdir ($target_folder) if (! -e $target_folder);
  @images = read_images($input_folder);
  foreach $i(@images) {
    print "$input_folder/$i\n";
    my ($study_uid, $series_uid, $instance_uid, $xfer_syntax) = extract_uids("$input_folder/$i");
    die "Unexpected transfer syntax $input_folder/$i $xfer_syntax" if (! ($xfer_syntax eq "1.2.840.10008.1.2.1"));
    my $output_path = "$target_folder/$study_uid/$series_uid/$instance_uid";
    print "$output_path\n";
    make_path($output_path) if (! -e $output_path);
    unlink "$output_folder/$xfer_syntax";
    my $z = "cp $input_folder/$i $output_path/$xfer_syntax";
    die "Could not execute $z" if `$z` != 0;

    compress_original($output_path, $xfer_syntax);
  }
}

xdsi::check_environment();

$count = scalar(@ARGV);
die "Arguments: source_folder target_folder" if ($count != 2);

@input_folders = read_folder($ARGV[0]);
foreach $f(@input_folders) {
 print "$f\n";
 process_folder("$ARGV[0]/$f/images", $ARGV[1]);
}
