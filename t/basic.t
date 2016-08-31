use v6;

use Test;
use Data::MessagePack;

plan 34;

my $data = True;

my $mp = Data::MessagePack.new();
ok $mp.pack( Any ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
ok $mp.pack( Bool ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
ok $mp.pack( False ) ~~ Blob.new( 0xc2 ), "Boolean False is packed correctly";
ok $mp.pack( True ) ~~ Blob.new( 0xc3 ), "Boolean True is packed correctly";



ok $mp.pack( 'abc') ~~ Blob.new( 0xa3, 0x61, 0x62, 0x63 ), "String packed correctly";
ok $mp.pack( 'More than 32 characters, for test' ) ~~ Blob.new(217,33,77,111,114,101,32,116,104,97,110,32,51,50,32,99,104,97,114,97,99,116,101,114,115,44,32,102,111,114,32,116,101,115,116), "String packed correctly";
;
ok $mp.pack( 'a' x 2**8 ) ~~ Blob.new( 0xda, 0x01, 0x00, 0x61 xx (2**8) ), "String packed correctly";
ok $mp.pack( 'a' x 2**16 ) ~~ Blob.new( 0xdb, 0x00, 0x01, 0x00, 0x00, 0x61 xx (2**16) ), "String packed correctly";

ok $mp.pack( Blob.new(1, 2, 3) ) ~~ Blob.new( 0xc4, 3, 1, 2, 3 ), "Bin packed correctly";
ok $mp.pack( Blob.new(13 xx 2**8) ) ~~ Blob.new( 0xc5, 0x01, 0x00, 13 xx (2**8) ), "Bin packed correctly";
ok $mp.pack( Blob.new(14 xx 2**16) ) ~~ Blob.new( 0xc6, 0x00, 0x01, 0x00, 0x00, 14 xx (2**16) ), "Bin packed correctly";

ok $mp.pack( 147.625 ) ~~ Blob.new(203,64,98,116,0,0,0,0,0), "Double packed correcly";
ok $mp.pack( -147.625 ) ~~ Blob.new(203,192,98,116,0,0,0,0,0), "Negative double packed correcly";

ok $mp.pack( 147.00 ) ~~ $mp.pack( 147 ), "Double with int value packed as int";

my @a = 1, 2, 3;
ok $mp.pack( @a ) ~~ Blob.new(147,1,2,3), "Small Array packed correctly";

my $l = 1 xx 20;
ok $mp.pack( $l ) ~~ Blob.new(220,0,20,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), "Medium list packed correctly";

my %h = key => 'value';
ok $mp.pack( %h ) ~~ Blob.new(129,163,107,101,121,165,118,97,108,117,101), "Hash packed correctly";
