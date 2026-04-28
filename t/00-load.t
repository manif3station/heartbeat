use strict;
use warnings;

use Test::More;

use lib 'lib';

require_ok('Heartbeat::CheckDD');
require_ok('Heartbeat::Server::Connected');

done_testing();
