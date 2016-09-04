use v6;
use Data::MessagePack::StreamingUnpacker;

my $supplier = Supplier.new;

my $supply = $supplier.Supply;

my $s = Data::MessagePack::StreamingUnpacker.new( source => $supplier.Supply );
my $unpacked = $s.Supply();
$unpacked.tap( -> $v { say "Got : {$v.perl}"; } );

for (0xc3,217,33,77,111,114,101,32,116,104,97,110,32,51,50,32,99,104,97,114,97,99,116,101,114,115,44,32,102,111,114,32,116,101,115,116,0xc2,0xc0) -> $byte {
    $supplier.emit( $byte );
}
