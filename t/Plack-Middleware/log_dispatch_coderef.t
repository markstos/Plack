use strict;
use Plack::Test;
# Hmm, problematic here because it preloads a module that we want to test they lazy-loading of.
# use Test::Requires qw(Log::Dispatch::Array);
use Test::More;
use Plack::Middleware::LogDispatch;
use HTTP::Request::Common;

my @logs;

my $app = sub {
    my $env = shift;
    $env->{'psgix.logger'}->({ level => "debug", message => "This is debug" });
    return [ 200, [], [] ];
};


# Since we are testing delayed loading, make sure the the modules aren't loaded yet.
# ( Apparently Test::Requires loads them. )
ok((not exists $INC{'Log/Dispatch.pm'}), "reality check: Log::Dispatch is not loaded yet"); 

$app = Plack::Middleware::LogDispatch->wrap($app, logger =>
    sub {
        require Log::Dispatch;
        require Log::Dispatch::Array;
        my $logger = Log::Dispatch->new;
        $logger->add(Log::Dispatch::Array->new(
            min_level => 'debug',
            array     => \@logs,));
    }
);

test_psgi $app, sub {
    my $cb = shift;
    my $res = $cb->(GET "/");

    is @logs, 1;
    is $logs[0]->{level}, 'debug';
    is $logs[0]->{message}, 'This is debug';

};

done_testing;
