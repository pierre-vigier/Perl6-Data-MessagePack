use v6;
use Test;
use Data::MessagePack::StreamingUnpacker;

plan 2;

my @to_send = 0, 1, 127,
    0xcc, 0x80,
    0xcc, 0xff,
;


# ok Data::MessagePack::pack( 256) ~~ Blob.new(0xcd, 0x01, 0x00), "Positive integer packed correctly";
# ok Data::MessagePack::pack( 65535) ~~ Blob.new(0xcd, 0xff, 0xff), "Positive integer packed correctly";
# ok Data::MessagePack::pack( 65536) ~~ Blob.new(0xce, 0x00, 0x01, 0x00, 0x00), "Positive integer packed correctly";
# ok Data::MessagePack::pack( 4294967295) ~~ Blob.new(0xce, 0xff, 0xff, 0xff, 0xff), "Positive integer packed correctly";
# ok Data::MessagePack::pack( 4294967296) ~~ Blob.new(0xcf, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00), "Positive integer packed correctly";
# ok Data::MessagePack::pack( 184467440737095) ~~ Blob.new(0xcf, 0x00, 0x00, 0xa7, 0xc5, 0xac, 0x47, 0x1b, 0x47), "Positive integer packed correctly";
# ok Data::MessagePack::pack( 2**64 -1 ) ~~ Blob.new(0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff), "Positive integer packed correctly";
# throws-like { Data::MessagePack::pack( 2**64 ); }, X::Data::MessagePack::Packer;


my @expected = 0, 1, 127, 128, 255;

my $supplier = Supplier.new;

my $supply = $supplier.Supply;

my $s = Data::MessagePack::StreamingUnpacker.new( source => $supplier.Supply );
my $unpacked = $s.Supply();
$unpacked.tap( -> $v {
    my $expected = @expected.shift;
    ok $expected eqv $v, "Expected value received";
} );

for @to_send -> $byte {
    $supplier.emit( $byte );
}
