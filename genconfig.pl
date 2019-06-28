#!/usr/bin/perl

use v5.10;
use Config::Tiny;
use Data::Dumper;
use Parallel::ForkManager;

$SIG{INT} = $SIG{TERM} = sub { exit };
my $max_forks = 30;
# 6 forks - 54 seconds
# 12 forks - 48 seconds
# 24 forks - 46 seconds
# 30 forks - 41 seconds
# 60 forks - 43 seconds

my $pm = Parallel::ForkManager->new($max_forks);
my $parent_pid = "$$";

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

DATA_LOOP:
foreach my $truck (@trucks)
{
	my $pid = $pm->start and next DATA_LOOP;
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
				
		# Handle truck-specific lines
		# These are marked with a comment starting with either "for" or "not" and then a list of comma separated trucks.
		my @for = `grep -in '# for ' $dir/def/vehicle/truck/$truck/$subdir/$file`;
		#my @not = `grep -in '# not ' $dir/def/vehicle/truck/$truck/$subdir/$file`;
		foreach my $line (@for)
		{
			my $line_number = (split(':', $line))[0];
			my @for_trucks = (split(',', (split(' ',$line))[-1]));
			my %truck_hash = ();
			$truck_hash{lc $_} = 1 foreach (@for_trucks);
			
			#say "sed -i '${line_number}s/^.*\$//' $dir/def/vehicle/truck/$truck/$subdir/$file" unless exists $truck_hash{lc $truck};
			`sed -i '${line_number}s/^.*\$//' $dir/def/vehicle/truck/$truck/$subdir/$file` unless exists $truck_hash{lc $truck};
		}
	}

	# Replace "%truck%" with the truck's def name
	`sed -i 's/%truck%/$truck/' $dir/def/vehicle/truck/$truck/*/*`;
	$pm->finish;
}
$pm->wait_all_children;


if ( exists $config->{$dir}{'install_to'} )
{
    my $dest = $config->{$dir}{'install_to'};
    say "Installing mod to $dest";

    `rm -r $dest/def`;
    `mv $dir/def $dest/`;
}
