#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Plack::Loader;
use Test::TCP;
use Getopt::Long;
use URI;
use String::ShellQuote;

my $app = 'eg/dot-psgi/Hello.psgi';
my $ab  = 'ab -t 1 -c 10 -k';
my $url = 'http://127.0.0.1/';

my @try = (
    [ 'AnyEvent::HTTPD' ],
    [ 'HTTP::Server::PSGI' ],
    [ 'HTTP::Server::PSGI', ' (workers=10)', max_workers => 10 ],
    [ 'Twiggy' ],
    [ 'HTTP::Server::Simple' ],
    [ 'Coro' ],
    [ 'Danga::Socket' ],
    [ 'POE' ],
    [ 'Starman', ' (workers=10)', workers => 10 ],
);

my @backends;

for my $handler (@try) {
    eval { Plack::Loader->load($handler->[0]) };
    push @backends, $handler unless $@;
}

warn "Testing implementations: ", join(", ", map $_->[0], @backends), "\n";

GetOptions(
    'a|app=s'   => \$app,
    'b|bench=s' => \$ab,
    'u|url=s'   => \$url,
) or die;

&main;

sub main {
    print <<EOF;
app: $app
ab:  $ab
URL: $url

EOF
    for my $handler (@backends) {
        run_one(@$handler);
    }
}

sub run_one {
    my($server_class, $how, @args) = @_;
    print "-- server: $server_class ", ($how || ''), "\n";

    test_tcp(
        client => sub {
            my $port = shift;
            my $uri = URI->new($url);
            $uri->port($port);
            $uri = shell_quote($uri);
            print `$ab $uri | grep 'Requests per '`;
        },
        server => sub {
            my $port = shift;
            my $handler = Plack::Util::load_psgi $app;
            my $server = Plack::Loader->load($server_class, port => $port, @args);
            $server->run($handler);
        },
    );
}


