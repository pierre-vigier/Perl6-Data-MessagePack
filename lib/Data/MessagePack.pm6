use v6;
class Data::MessagePack {
    multi method pack( Any:U $object ) {
        Blob.new(0xc0);
    }
    multi method pack( Bool:D $b ) {
        $b??Blob.new(0xc3)!!Blob.new(0xc2);
    }

    multi method pack( Int:D $i ) {
        given $i {
            when * < -2**31 {
                my @segments;
                my $copy = $i;
                for (56, 48, 40, 32, 24 , 16, 8, 0) -> $e {
                    @segments.push( $copy div 2**$e );
                    $copy %= 2**$e;
                }
                return Blob.new( 0xd3, @segments );
            }
            when * < -2**15 {
                my @segments;
                my $copy = $i;
                for (24, 16, 8, 0) -> $e {
                    @segments.push( $copy div 2**$e );
                    $copy %= 2**$e;
                }
                return Blob.new( 0xd2, @segments );
            }
            when * < -2**7 { return Blob.new( 0xd1, $i div 256, $i % 256 )}
            when * < -32 { return Blob.new( 0xd0, $i ) }
            when * < 0 { return Blob.new( $i +& 255 ) }
            when * < 128 { return Blob.new( $i ) }
            when * < 2**8 { return Blob.new( 0xcc, $i ) }
            when * < 2**16 {
                #until i find a way to pack the value
                return Blob.new( 0xcd, $i div 256, $i % 256 );
            }
            when * < 2**32 {
                my @segments;
                my $copy = $i;
                for (24, 16, 8, 0) -> $e {
                    @segments.push( $copy div 2**$e );
                    $copy %= 2**$e;
                }
                return Blob.new( 0xce, @segments );
            }
            default {
                my @segments;
                my $copy = $i;
                for (56, 48, 40, 32, 24, 16, 8, 0) -> $e {
                    @segments.push( $copy div 2**$e );
                    $copy %= 2**$e;
                }
                return Blob.new( 0xcf, @segments );
            }
        }
    }
};

# vim: ft=perl6
