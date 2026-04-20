use strict;
use warnings;

use Test::More;

use lib 'lib';
use Heartbeat::CheckDD;

is(
    Heartbeat::CheckDD::render_payload( epoch => 12345 ),
    '{"now":45}',
    'module preserves the current payload behavior for a supplied epoch'
);

my $output = qx{$^X cli/check-dd};
my $exit = $? >> 8;

is( $exit, 0, 'cli/check-dd exits cleanly' );
like( $output, qr/\A\{"now":\d+\}\z/, 'cli/check-dd prints a valid payload' );

done_testing();
