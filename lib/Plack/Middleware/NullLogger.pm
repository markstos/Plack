package Plack::Middleware::NullLogger;
use strict;

sub call {
    my($self, $env) = @_;
    $env->{'psgix.logger'} = sub { };
    $self->app->($env);
}

1;

__END__

=head1 NAME

Plack::Middleware::NullLogger - Send logs to /dev/null

=head1 SYNOPSIS

  enable "NullLogger";

  # Now logging calls like this to $env->{'psgix.logger'} will have no effect:
  $env->{'psgix.logger'}->({ level => "debug", message => "This is debug" });

=head1 DESCRIPTIOM

NullLogger is a middleware component that receives logs and does
nothing but discard them. Might be useful to shut up all the logs
from frameworks in one shot.

=head1 AUTHOR

Tatsuhiko Miyagawa

=cut
