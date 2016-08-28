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
