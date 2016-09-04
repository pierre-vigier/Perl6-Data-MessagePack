use v6;

class Data::MessagePack::StreamingUnpacker {
    has Supply    $.source;
    has Supplier  $!supplier;
    has Buf       $!queue;
    has Int       $!length-byte = 0;
    has Int       $!length = 0;
    has Int       $!remaining-bytes = 0;
    has Str       $!decoding = Str;
    has           &!next;

    submethod BUILD ( :$!source ){
        $!supplier = Supplier.new;
        $!queue = Buf.new();
        $!source.tap( -> $v { self!process_input( $v) });
    }

    method Supply returns Supply {
        $!supplier.Supply;
    }

    method !process_input( $byte ) {
        say "processing $byte";
        if ! $!decoding.defined {
            #nothing in queue, start a new decode loop
            given $byte {
                when 0xc0 { $!supplier.emit( Any ); }
                when 0xc2 { $!supplier.emit( False ) }
                when 0xc3 { $!supplier.emit( True ) }
                when 0xd9 {
                    say "It's a string";
                    # &!next =
                    $!decoding = 'String';
                    $!length-byte = 1;
                    #_unpack-string($b, $position, _unpack-uint( $b, $position, 1 ))
                }
            }
        } else {
            #continue a current structure
            #should i read a length byte?
            if $!length-byte {
                $!length +<= 8;
                $!length += $byte;
                unless --$!length-byte {
                    say "Number of characters : $!length";
                    $!remaining-bytes = $!length;
                    $!length = 0;
                }
            } elsif $!remaining-bytes > 0 {
                $!queue.push( $byte );
                unless --$!remaining-bytes {
                    $!supplier.emit( $!queue.decode );
                    $!queue = Buf.new();
                    $!decoding = Str;
                }
            }
        }
        # $!queue.push( $byte );
        #
        # if $!queue.elems == 2 {
        #     $!supplier.emit( $!queue.shift + $!queue.shift );
        # }
    }

    method !process-string( $byte ) {

    }
}
