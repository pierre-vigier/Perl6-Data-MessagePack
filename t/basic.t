use v6;

use Test;
use Data::MessagePack;

my $data = True;

my $mp = Data::MessagePack.new();
ok $mp.pack( Any ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
ok $mp.pack( Bool ) ~~ Blob.new( 0xc0 ), "Undefined is packed correctly";
ok $mp.pack( False ) ~~ Blob.new( 0xc2 ), "Boolean False is packed correctly";
ok $mp.pack( True ) ~~ Blob.new( 0xc3 ), "Boolean True is packed correctly";
ok $mp.pack( 1 ) ~~ Blob.new( 0x01 ), "Integer 1 True is packed correctly";

#integers
ok $mp.pack( -16 ) ~~ Blob.new(0xf0), "Negative integer packed correctly";
ok $mp.pack( -70 ) ~~ Blob.new(0xd0, 0xba), "Negative integer packed correctly";
ok $mp.pack( -150 ) ~~ Blob.new(0xd1, 0xff, 0x6a), "Negative integer packed correctly";
ok $mp.pack( -35768 ) ~~ Blob.new(0xd2, 0xff, 0xff, 0x74, 0x48), "Negative integer packed correctly";
ok $mp.pack( -2147483645 ) ~~ Blob.new(0xd2, 0x80, 0x00, 0x00, 0x03), "Negative integer packed correctly";
ok $mp.pack( -2147483800 ) ~~ Blob.new(0xd3, 0xff, 0xff, 0xff, 0xff, 0x7f, 0xff, 0xff, 0x68), "Negative integer packed correctly";

ok $mp.pack( 1) ~~ Blob.new(0x01), "Positive integer packed correctly";
ok $mp.pack( 127) ~~ Blob.new(0x7f), "Positive integer packed correctly";
ok $mp.pack( 128) ~~ Blob.new(0xcc, 0x80), "Positive integer packed correctly";
ok $mp.pack( 255) ~~ Blob.new(0xcc, 0xff), "Positive integer packed correctly";
ok $mp.pack( 256) ~~ Blob.new(0xcd, 0x01, 0x00), "Positive integer packed correctly";
ok $mp.pack( 65535) ~~ Blob.new(0xcd, 0xff, 0xff), "Positive integer packed correctly";
ok $mp.pack( 65536) ~~ Blob.new(0xce, 0x00, 0x01, 0x00, 0x00), "Positive integer packed correctly";
ok $mp.pack( 4294967295) ~~ Blob.new(0xce, 0xff, 0xff, 0xff, 0xff), "Positive integer packed correctly";
ok $mp.pack( 4294967296) ~~ Blob.new(0xcf, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00), "Positive integer packed correctly";
ok $mp.pack( 184467440737095) ~~ Blob.new(0xcf, 0x00, 0x00, 0xa7, 0xc5, 0xac, 0x47, 0x1b, 0x47), "Positive integer packed correctly";

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

#my $l = 1 xx 2**16;
#say $mp.pack( $l );
