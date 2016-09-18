use v6.c;
use lib 'lib';

use Data::MessagePack;
for ^1000 {
    my $b = Data::MessagePack::pack( 658003 );
}
say "done";

