package Heartbeat::CheckDD;

use strict;
use warnings;

sub render_payload {
    my (%args) = @_;
    my $epoch = defined $args{epoch} ? $args{epoch} : time;
    my ( $n, $m ) = reverse split //, $epoch . q{};
    return sprintf '{"now":%d}', "$m$n";
}

1;
