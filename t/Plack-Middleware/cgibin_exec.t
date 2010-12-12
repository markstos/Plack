use strict;
use Test::More;
use Test::Requires { 'CGI::Emulate::PSGI' => 0.10, 'CGI::Compile' => 0.03 };
use Plack::Test;
use HTTP::Request::Common;
use Plack::App::CGIBin;

unless (-e "/usr/bin/python" && -x _) {
    plan skip_all => "You don't have /usr/bin/python";
}

my $app = Plack::App::CGIBin->new(root => "t/Plack-Middleware/cgi-bin")->to_app;

test_psgi app => $app, client => sub {
    my $cb = shift;

    my $res = $cb->(GET "http://localhost/hello.py?name=foo");
    is $res->code, 200;
    like $res->content, qr/Hello foo/;
    like $res->content, qr/QUERY_STRING is name=foo/;
};

done_testing;
