use v6;

unit module Data::MessagePack;
use Data::MessagePack::Packer;

our sub pack( *@params ) {
    Data::MessagePack::Packer::pack( |@params );
}

# vim: ft=perl6
