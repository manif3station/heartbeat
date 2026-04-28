package Heartbeat::Server::Connected;

use strict;
use warnings;

use JSON::PP qw(encode_json);
use Socket qw(AF_INET SOCK_STREAM inet_aton inet_ntoa sockaddr_in);

sub cli_response {
    my (@argv) = @_;
    my $host = shift @argv;
    return (
        encode_json(
            {
                status  => 'usage_error',
                message => 'dashboard heartbeat.server.connected <host> [port]',
            }
        ),
        1,
    ) if !defined $host || $host eq q{};

    my $port = shift @argv;
    $port = 80 if !defined $port || $port eq q{};
    $port = 0 + $port if $port =~ /^\d+\z/;

    my $result = run_check(
        host => $host,
        port => $port,
    );
    return ( encode_json($result), exit_code_for_status( $result->{status} ) );
}

sub run_cli {
    my (@argv) = @_;
    my ( $json, $exit ) = cli_response(@argv);
    print $json;
    return $exit;
}

sub run_check {
    my (%args) = @_;
    my $host = $args{host};
    my $port = $args{port};
    my $status = check_host_reachable( $host, $port );
    return {
        host      => $host,
        port      => $port,
        status    => lc $status,
        reachable => $status eq 'UP' ? 1 : 0,
    };
}

sub check_host_reachable {
    my ( $host, $port ) = @_;
    my $ip;

    if ( is_ip_address($host) ) {
        $ip = $host;
    }
    else {
        my @res = gethostbyname($host);
        return 'DNS_ERROR' if !@res;
        $ip = inet_ntoa( $res[4] );
    }

    return check_via_ip( $ip, $port );
}

sub is_ip_address {
    my ($ip) = @_;
    return $ip =~ /^(\d{1,3}\.){3}\d{1,3}\z/ ? 1 : 0;
}

sub check_via_ip {
    my ( $ip, $port ) = @_;
    my $iaddr = inet_aton($ip) or return 'DOWN';
    my $paddr = sockaddr_in( $port, $iaddr );

    socket( my $sock, AF_INET, SOCK_STREAM, 0 ) or return 'DOWN';
    my $ok = connect( $sock, $paddr ) ? 1 : 0;
    close $sock;

    return $ok ? 'UP' : 'DOWN';
}

sub exit_code_for_status {
    my ($status) = @_;
    return 0 if ( $status || q{} ) eq 'up';
    return 2 if ( $status || q{} ) eq 'dns_error';
    return 1;
}

1;
