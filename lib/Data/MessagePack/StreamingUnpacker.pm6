use v6;

class Data::MessagePack::StreamingUnpacker {
    has Supply    $.source;
    has Supplier  $!supplier;

    has           $!next;

    submethod BUILD ( :$!source ){
        $!supplier = Supplier.new;
        $!source.tap( -> $v { self!process_input( $v) });
    }

    method Supply returns Supply {
        $!supplier.Supply;
    }

    method !process_input( $byte ) {

        if $!next.defined {
            $!next = $!next.( $byte );
            return;
        }

        #nothing in queue, start a new decode loop
        given $byte {
            when 0xc0 { $!supplier.emit( Any ); }
            when 0xc2 { $!supplier.emit( False ) }
            when 0xc3 { $!supplier.emit( True ) }
            when 0xd9 {
                $!next = process-string( length-bytes => 1, supplier => $!supplier );
            }
            #uint
            when 0xcc { $!next = process-uint( length-bytes => 1, supplier => $!supplier ); }
            when 0xcd { $!next = process-uint( length-bytes => 2, supplier => $!supplier ); }
            when 0xce { $!next = process-uint( length-bytes => 4, supplier => $!supplier ); }
            when 0xcf { $!next = process-uint( length-bytes => 8, supplier => $!supplier ); }
            #int
            # when 0xd0 { _unpack-uint( $b, $position, 1 ) -^ 0xff - 1 }
            # when 0xd1 { _unpack-uint( $b, $position, 2 ) -^ 0xffff - 1 }
            # when 0xd2 { _unpack-uint( $b, $position, 4 ) -^ 0xffffffff - 1 }
            # when 0xd3 { _unpack-uint( $b, $position, 8 ) -^ 0xffffffffffffffff - 1 }

            #positive fixint 0xxxxxxx	0x00 - 0x7f
            when * +& 0b10000000 == 0 { $!supplier.emit($_) }
        }
    }

    sub process-uint( :$length-bytes, :$supplier ) {
        my $remaining-bytes = $length-bytes;
        my $value = 0;
        return sub ($byte) {
            if $remaining-bytes {
                $value +<= 8; $value += $byte;
                $remaining-bytes--;
                return &?BLOCK;
            } else {
                $supplier.emit( $value );
                return Nil;
            }
        };
    }

    sub process-string( :$length-bytes, :$supplier ) {
        my $remaining-bytes = $length-bytes;
        my $length = 0;
        my $buf = Buf.new;
        return sub ($byte) {
            if $remaining-bytes {
                $length +<= 8; $length += $byte;
                $remaining-bytes--;
                return &?BLOCK;
            } else {
                $buf.push( $byte );
                if --$length {
                    return &?BLOCK;
                } else {
                    $supplier.emit( $buf.decode );
                    return Nil;
                }
            }
        };
    }
    # method !process-string($inv: $byte, :$length, :$length-bytes, :$buf ) {
    #     say "Invocant ps $inv , $byte, $length, $length-bytes";
    #     if $length-bytes {
    #         my $l = $length;
    #         $l +<= 8; $l += $byte;
    #         say "length $l";
    #         return -> $b { self!process-string( $b, length => $l, length-bytes => $length-bytes - 1 ); }
    #     }
    #     #processing of the string
    #     if $length == 0 {
    #         $!supplier.emit( $buf.decode );
    #         return Callable;
    #     }
    #
    #     my $bu = $buf.defined??$buf!!Buf.new();
    #     $bu.push( $byte );
    #     return -> $b { self!process-string( $b, length => $length - 1, :length-bytes(0), buf => $bu ) }
    # }
}
