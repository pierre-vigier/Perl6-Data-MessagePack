use v6;

class Data::MessagePack::StreamingUnpacker {
    has Supply    $.source;
    has Supplier  $!supplier;

    has           $!next;

    submethod BUILD ( :$!source ){
        $!supplier = Supplier.new;
        $!source.tap( -> $v { self!process_input( $v) }, done => {
            $!supplier.done();
        });
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
            when 0xc2 { $!supplier.emit( False ); }
            when 0xc3 { $!supplier.emit( True ); }
            when 0xd9 { $!next = process-string( length-bytes => 1, supplier => $!supplier ); }
            #floats
            when 0xca { $!next = process-float( supplier => $!supplier ); }
            when 0xcb { $!next = process-double( supplier => $!supplier ); }
            #uint
            when 0xcc { $!next = process-uint( length-bytes => 1, supplier => $!supplier ); }
            when 0xcd { $!next = process-uint( length-bytes => 2, supplier => $!supplier ); }
            when 0xce { $!next = process-uint( length-bytes => 4, supplier => $!supplier ); }
            when 0xcf { $!next = process-uint( length-bytes => 8, supplier => $!supplier ); }
            #int
            when 0xd0 { $!next = process-int( length-bytes => 1, supplier => $!supplier ); }
            when 0xd1 { $!next = process-int( length-bytes => 2, supplier => $!supplier ); }
            when 0xd2 { $!next = process-int( length-bytes => 4, supplier => $!supplier ); }
            when 0xd3 { $!next = process-int( length-bytes => 8, supplier => $!supplier ); }

            #positive fixint 0xxxxxxx	0x00 - 0x7f
            when * +& 0b10000000 == 0 { $!supplier.emit($_) }
            #negative fixint 111xxxxx	0xe0 - 0xff
            when * +& 0b11100000 == 0b11100000 { $!supplier.emit($_ +& 0x1f -^ 0x1f - 1) }
        }
    }

    sub process-uint( :$length-bytes, :$supplier ) {
        my $remaining-bytes = $length-bytes;
        my $value = 0;
        return sub ($byte) {
            $value +<= 8; $value += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                $supplier.emit( $value );
                return Nil;
            }
        };
    }

    sub process-int( :$length-bytes, :$supplier ) {
        my $remaining-bytes = $length-bytes;
        my $value = 0;
        my $mask = :16("FF" x $length-bytes);
        return sub ($byte) {
            $value +<= 8; $value += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                $supplier.emit( $value -^ $mask - 1 );
                return Nil;
            }
        };
    }

    sub process-float( :$supplier ) {
        my $remaining-bytes = 4;
        my $raw = 0;

        return sub ( $byte ) {
            $raw +<= 8;
            $raw += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                if $raw == 0 {
                    $supplier.emit( 0 );
                } else {
                    my $s = $raw +& 0x80000000 ?? -1 !! 1;
                    my $exp = ( $raw +> 23 ) +& 0xff;
                    $exp -= 127;
                    my $mantissa = $raw +& 0x7FFFFF;
                    $mantissa = 1 + ( $mantissa / 2**23 );
                    $supplier.emit( $s * $mantissa * 2**$exp );
                }
                return Nil;
            }
        }
    }

    sub process-double( :$supplier ) {
        my $remaining-bytes = 8;
        my $raw = 0;

        return sub ( $byte ) {
            $raw +<= 8;
            $raw += $byte;
            if --$remaining-bytes {
                return &?BLOCK;
            } else {
                if $raw == 0 {
                    $supplier.emit( 0 );
                } else {
                    my $s = $raw +& 0x8000000000000000 ?? -1 !! 1;
                    my $exp = ( $raw +> 52 ) +& 0x7ff;
                    $exp -= 1023;
                    my $mantissa = $raw +& 0x0FFFFFFFFFFFFF;
                    $mantissa = 1 + ( $mantissa / 2**52 );
                    $supplier.emit( $s * $mantissa * 2**$exp );
                }
                return Nil;
            }
        }
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
