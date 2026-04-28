use strict;
use warnings;

use IO::Socket::INET;
use JSON::PP qw(decode_json);
use Test::More;

use lib 'lib';

use Heartbeat::Server::Connected;

my $listener = IO::Socket::INET->new(
    LocalAddr => '127.0.0.1',
    LocalPort => 0,
    Proto     => 'tcp',
    Listen    => 1,
    ReuseAddr => 1,
) or die "Unable to create listener: $!";

my $up_port = $listener->sockport;

my $up = _with_accept_once(
    $listener,
    sub {
        return Heartbeat::Server::Connected::run_check(
            host => '127.0.0.1',
            port => $up_port,
        );
    },
);
is( $up->{status}, 'up', 'run_check reports an open localhost port as up' );
is( $up->{reachable}, 1, 'run_check marks reachable targets as true' );
is( $up->{port}, $up_port, 'run_check preserves the supplied port' );

my $down_port = $up_port + 1;
my $down = Heartbeat::Server::Connected::run_check(
    host => '127.0.0.1',
    port => $down_port,
);
is( $down->{status}, 'down', 'run_check reports a closed localhost port as down' );
is( $down->{reachable}, 0, 'run_check marks unreachable targets as false' );

my $dns = Heartbeat::Server::Connected::run_check(
    host => 'missing-host.invalid',
    port => 80,
);
is( $dns->{status}, 'dns_error', 'run_check reports DNS failures explicitly' );
is( $dns->{reachable}, 0, 'dns failures are not marked reachable' );

my $hostname_up = _with_accept_once(
    $listener,
    sub {
        return Heartbeat::Server::Connected::run_check(
            host => 'localhost',
            port => $up_port,
        );
    },
);
is( $hostname_up->{status}, 'up', 'run_check resolves ordinary hostnames before probing' );

is( Heartbeat::Server::Connected::exit_code_for_status('up'),        0, 'up exit code is zero' );
is( Heartbeat::Server::Connected::exit_code_for_status('down'),      1, 'down exit code is one' );
is( Heartbeat::Server::Connected::exit_code_for_status('dns_error'), 2, 'dns error exit code is two' );
is( Heartbeat::Server::Connected::exit_code_for_status('weird'),     1, 'unexpected statuses fall back to one' );

ok( Heartbeat::Server::Connected::is_ip_address('127.0.0.1'), 'IPv4 dotted quads are recognized as IP addresses' );
ok( !Heartbeat::Server::Connected::is_ip_address('localhost'), 'hostnames are not treated as IP addresses' );

my ( $usage_json, $usage_exit ) = Heartbeat::Server::Connected::cli_response();
my $usage = decode_json($usage_json);
is( $usage_exit, 1, 'missing arguments return usage failure' );
is( $usage->{status}, 'usage_error', 'usage response has usage_error status' );
like( $usage->{message}, qr/\Adashboard heartbeat\.server\.connected <host> \[port\]\z/, 'usage response explains the required arguments' );

my ( $cli_json, $cli_exit ) = _with_accept_once(
    $listener,
    sub {
        return [ Heartbeat::Server::Connected::cli_response( '127.0.0.1', $up_port ) ];
    },
)->@*;
my $cli = decode_json($cli_json);
is( $cli_exit, 0, 'cli_response returns a zero exit code for reachable targets' );
is( $cli->{status}, 'up', 'cli_response returns the expected status payload' );
is( $cli->{port}, $up_port, 'cli_response preserves the target port in its payload' );

my $run_cli_output = q{};
my $run_cli_exit = _with_accept_once(
    $listener,
    sub {
        open my $stdout, '>', \$run_cli_output or die "Unable to open scalar stdout: $!";
        local *STDOUT = $stdout;
        return Heartbeat::Server::Connected::run_cli( '127.0.0.1', $up_port );
    },
);
is( $run_cli_exit, 0, 'run_cli returns zero for reachable targets' );
my $run_cli_payload = decode_json($run_cli_output);
is( $run_cli_payload->{status}, 'up', 'run_cli prints the JSON payload to stdout' );

my $cli_output = _with_accept_once(
    $listener,
    sub {
        return scalar qx{$^X skills/server/cli/connected 127.0.0.1 $up_port};
    },
);
my $cli_status = $? >> 8;
my $cli_payload = decode_json($cli_output);
is( $cli_status, 0, 'nested CLI exits cleanly for reachable targets' );
is( $cli_payload->{status}, 'up', 'nested CLI prints JSON payload' );
is( $cli_payload->{host}, '127.0.0.1', 'nested CLI payload includes the target host' );

my $cli_down = qx{$^X skills/server/cli/connected 127.0.0.1 $down_port};
my $cli_down_status = $? >> 8;
my $cli_down_payload = decode_json($cli_down);
is( $cli_down_status, 1, 'nested CLI exits nonzero for unreachable targets' );
is( $cli_down_payload->{status}, 'down', 'nested CLI reports down targets' );

done_testing();

sub _with_accept_once {
    my ( $listener, $code ) = @_;
    my $accept_pid = fork();
    die 'Unable to fork accept helper' if !defined $accept_pid;
    if ( $accept_pid == 0 ) {
        my $client = $listener->accept();
        close $client if $client;
        exit 0;
    }

    my $result = $code->();
    waitpid $accept_pid, 0;
    return $result;
}
