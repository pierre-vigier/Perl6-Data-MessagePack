use v6;

unit module Data::MessagePack;
use Data::MessagePack::Packer;
use Data::MessagePack::Unpacker;

our sub pack( $params ) {
    Data::MessagePack::Packer::pack( $params );
}

our sub unpack( Blob $blob ) {
    Data::MessagePack::Unpacker::unpack( $blob );
}
# vim: ft=perl6
