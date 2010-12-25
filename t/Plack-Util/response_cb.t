use strict;
use Test::Requires qw(IO::Handle::Util);
use Test::More;
use Plack::Util;
use IO::Handle::Util qw(:io_from);

my $simple_response_array_filter =  sub {
    my $res = shift;
    $res->[2][0] = 'hello moon';
    # $res is modified by reference. Nothing to return.
};

my $simple_response_body_filter =  sub {
    return sub {
        my $line = shift;
        return 'replaced by body filter';
    }
};

my $delayed_res = sub {
    my $respond = shift;
    my $basic_res = [ 200, [ 'Content-Type' => 'text/html' ], ['hello world']];
    $respond->($basic_res);
};

############################

{
    my $label = 'Case: three element response with arrayref of lines, modify by reference';
    my $basic_res = [ 200, [ 'Content-Type' => 'text/html' ], ['hello world']];
    my $new_res = Plack::Util::response_cb($basic_res,$simple_response_array_filter);
    is($new_res->[2][0], 'hello moon', $label );
    is($new_res, $basic_res, 'response_cb($aref): input modified by reference');
}
{
    my $label = 'Case: three element response with arrayref of lines, and body callback filter';
    my $basic_res = [ 200, [ 'Content-Type' => 'text/html' ], ['hello world']];
    my $new_res = Plack::Util::response_cb($basic_res,$simple_response_body_filter);
    is($new_res->[2][0], 'replaced by body filter', $label );
    is($new_res, $basic_res, 'response_cb($aref): input modified by reference');
}
{
    my $label = 'Case: three element response with IO::Handle-like object, and body callback filter';
    my $basic_res = [ 200, [ 'Content-Type' => 'text/html' ], io_from_array ['hello world']];
    my $new_res = Plack::Util::response_cb($basic_res,$simple_response_body_filter);
    is($new_res->[2]->getline, 'replaced by body filter', $label );
    is($new_res, $basic_res, 'response_cb($aref): input modified by reference');

}
# {
#     # Case: delayed coderef response, modify headers by reference
#     # TODO
# }
# {
#     # Case: delayed coderef response with body filter callback and arrayref of lines
#     # TODO
# }
# {
#     # Case: delayed coderef response with body filter callback and IO::Handle-like object
#     # TODO
# }


done_testing;
