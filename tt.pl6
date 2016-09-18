use v6.c;
use lib 'lib';

unit module Test;
use NativeCall;
use LibraryMake;

enum msgpack_object_type is repr('CStruct') (
    MSGPACK_OBJECT_NIL                  => 0x00,
    MSGPACK_OBJECT_BOOLEAN              => 0x01,
    MSGPACK_OBJECT_POSITIVE_INTEGER     => 0x02,
    MSGPACK_OBJECT_NEGATIVE_INTEGER     => 0x03,
    MSGPACK_OBJECT_FLOAT                => 0x04,
    MSGPACK_OBJECT_STR                  => 0x05,
    MSGPACK_OBJECT_ARRAY                => 0x06,
    MSGPACK_OBJECT_MAP                  => 0x07,
    MSGPACK_OBJECT_BIN                  => 0x08,
    MSGPACK_OBJECT_EXT                  => 0x09
);

class msgpack_object_array is repr('CStruct') {
    has uint32 $.size;
    has Pointer[void] $.ptr; #struct msgpack_object* ptr;
}

class msgpack_object_map is repr('CStruct') {
    has uint32 $.size;
    has Pointer[void] $.ptr; #struct msgpack_object_kv* ptr;
}

class msgpack_object_str is repr('CStruct') {
    has uint32 $.size;
    has Str $.ptr;
}

class msgpack_object_bin is repr('CStruct') {
    has uint32 $.size;
    has Str $.ptr;
}

class msgpack_object_ext is repr('CStruct') {
    has int8 $.type;
    has uint32 $.size;
    has Pointer[void] $.ptr; #const char* ptr;
};

class msgpack_object_union is repr('CUnion') {
    has bool $.boolean;
    has uint64 $.u64;
    has num64 $.f64;
    has msgpack_object_array $.array;
    has msgpack_object_map $.map;
    has msgpack_object_str $.str;
    has msgpack_object_bin $.bin;
    has msgpack_object_ext $.ext;
};

class msgpack_object is repr('CStruct') {
    has int8 $.type;
    has msgpack_object_union $.via;
}

class msgpack_object_kv is repr('CStruct') {
    has msgpack_object $.key;
    has msgpack_object $.val;
}

sub libdatamsgpack {
    my $so = get-vars('')<SO>;
    #return ~(%?RESOURCES{"lib/libdatamsgpack$so"});
    #return "resources/lib/libdatamsgpack$so";
    return "resources/lib/libdatamsgpack$so";
}

class msgpack_sbuffer is repr('CStruct') {
    has size_t $.size;
    has CArray[int8] $.data;
    has size_t $.alloc;
}

sub serialize_int( int32, msgpack_sbuffer is rw ) is native( &libdatamsgpack ) { * };

sub deserialize( CArray[int8], size_t , msgpack_object is rw ) is native( &libdatamsgpack ) { * };
sub deserialize2( CArray[int8], size_t , int8 is rw ) is native( &libdatamsgpack ) { * };
my $data = msgpack_sbuffer.new;
#for ^1000 {
    serialize_int(658003, $data);

    my $b = Buf.new();
    for ^$data.size -> $i { $b.push( $data.data[$i] ) };
#}
say $b;
my $a = CArray[int8].new( $b.list );
my $msg_obj = msgpack_object.new;
deserialize( $a, $b.elems, $msg_obj );

say "type "~$msg_obj.type;

my int8 $type;
deserialize2( $a, $b.elems, $type );

say "Type : $type";
say "done";
