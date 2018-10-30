#!/usr/bin/perl

use v5.10;
use Config::Tiny;

my $dir = $ARGV[0] // ".";
say "Processing $dir/*.sii";

opendir my $dh, $dir or die "Cannot open current directory: $!";
my @files = readdir $dh;
closedir $dh;

# Config File
my $config_file = 'config.ini';
my $config = Config::Tiny->read($config_file, 'utf8');

#my $trucks = "./trucks.txt";
my $trucks = $config->{$dir}{'trucks'} // "./trucks.txt"; $trucks =~ s/"//g;
say "Using trucks file: $trucks";

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

if ( exists $config->{$dir}{'install_to'} )
{
    my $dest = $config->{$dir}{'install_to'};
    say "Installing mod to $dest";

    `rm -r $dest/def`;
    `mv $dir/def $dest/`;
}
