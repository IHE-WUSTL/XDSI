#!/usr/bin/perl

sub exist_or_die {
 my ($f) = @_;
 die "Folder/file does not exist: $f\n" if ! -e $f;
}

sub create_one_link {
 my ($target, $src) = @_;
 my $x = "ln -s $src $target";
 print "$x\n";
 print `$x`;
 die "Could not execute $x\n" if $?;
}

sub create_storage_links {
 while (scalar(@_) >= 2) {
  my $target = shift @_;
  my $src    = shift @_;
  create_one_link($target, $src);
 }
}


#### Main starts here

# Check that folders exist

$base="/opt/xdsi/xds-toolkit/01/simdb";
$storage_base="/opt/xdsi/storage";
@folders = (
	$base, "$base/acme__rig_ids_a1", "$base/acme__rig_ids_a2",
	$base, "$base/acme__rig_ids_b1", "$base/acme__rig_ids_c1",
	$storage_base, "$storage_base/ids-community-A", "$storage_base/ids-community-B",
		       "$storage_base/ids-community-C");

foreach $f(@folders) {
 print "$f\n";
 exist_or_die($f);
}


# Create links from data to simulators
@storage_folders = (
	"$base/acme__rig_ids_a1/ids-repository", "$storage_base/ids-community-A",
	"$base/acme__rig_ids_a2/ids-repository", "$storage_base/ids-community-A",
	"$base/acme__rig_ids_b1/ids-repository", "$storage_base/ids-community-B",
	"$base/acme__rig_ids_c1/ids-repository", "$storage_base/ids-community-C");
create_storage_links(@storage_folders);
