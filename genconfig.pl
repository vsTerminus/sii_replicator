#!/usr/bin/perl

use v5.10;

my $dir = $ARGV[0] // ".";

opendir my $in, $dir or die "Cannot open current directory: $!";
my @files = readdir $in;
closedir $in;


my $trucks = $dir . "/trucks.txt";
open my $fh, "<", $trucks;
my @trucks = <$fh>;
close @trucks;

foreach my $truck (@trucks)
{
    chomp $truck;
    say "Generating config for $truck...";

    `mkdir -p $dir/def/vehicle/truck/$truck/sound/`;
    `mkdir -p $dir/def/vehicle/truck/$truck/engine/`;
	`mkdir -p $dir/def/vehicle/truck/$truck/transmission/`;

    foreach my $file (@files)
    {
        next unless $file =~ /\.sii$/i;
        my $subdir = 'engine';
        # Sound File
        $subdir = 'sound' if ( $file =~ /^(in|ex)terior_/ );
		
		# Transmission File
		$subdir = 'transmission' if ( $file =~ /speed.sii$/ );
		
        `cp $dir/$file $dir/def/vehicle/truck/$truck/$subdir/`;
    }

    `sed -i 's/%truck%/$truck/' $dir/def/vehicle/truck/$truck/*/*`;
}
