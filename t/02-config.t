use strict;
use warnings;
use utf8;

use JSON::PP qw(decode_json);
use Test::More;

my $config_path = 'config/config.json';
open my $fh, '<', $config_path or die "Unable to read $config_path: $!";
local $/;
my $json = <$fh>;
close $fh or die "Unable to close $config_path: $!";

my $config = decode_json($json);
is( ref $config->{collectors}, 'ARRAY', 'config declares collectors as an array' );
is( scalar @{ $config->{collectors} }, 1, 'config declares one collector' );

my $collector = $config->{collectors}[0];
is( $collector->{name}, 'check-dd', 'collector name matches expected value' );
is( $collector->{command}, 'dashboard heartbeat.check-dd', 'collector command dispatches the skill command' );
is( $collector->{interval}, 5, 'collector interval matches expected value' );
is( $collector->{cwd}, 'home', 'collector cwd matches expected value' );
is( $collector->{indicator}{icon}, '❤️[% now %]', 'collector indicator icon template matches expected value' );

done_testing();
