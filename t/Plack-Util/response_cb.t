use strict;
use Test::More;
use Plack::Util;

{
    my $basic_res = [ 200, [ 'Content-Type' => 'text/html' ], ['hello world']];
    my $cb = sub {
        my $res = shift;
        $res->[2][0] = 'hello moon';
        # res is modified by reference. Nothing to return.
    };

    my $new_res = Plack::Util::response_cb($basic_res,$cb);
    is($new_res->[2][0], 'hello moon', 'response_cb($aref): reality check');
    is($new_res, $basic_res, 'response_cb($aref): input modified by reference');
}

done_testing;
