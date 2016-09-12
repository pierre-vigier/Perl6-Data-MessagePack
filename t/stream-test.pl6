use v6;
use Test;
use Data::MessagePack::StreamingUnpacker;

my @to_send = 0xc3,217,33,77,111,114,101,32,116,104,97,110,32,51,50,32,99,104,97,114,97,99,116,101,114,115,44,32,102,111,114,32,116,101,115,116,0xc2,0xc0;

my @expected = True, "More than 32 characters, for test", False, Any;

my $supplier = Supplier.new;

my $supply = $supplier.Supply;

my $s = Data::MessagePack::StreamingUnpacker.new( source => $supplier.Supply );
my $unpacked = $s.Supply();
$unpacked.tap( -> $v {
    my $expected = @expected.shift;
    ok $expected eqv $v, "Expected value received";
#    say "Got : {$v.perl}";
} );

for @to_send -> $byte {
    $supplier.emit( $byte );
}