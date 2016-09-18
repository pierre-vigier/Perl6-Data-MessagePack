use v6;

#module Packer {
    use NativeCall;

enum msgpack_object_type (
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

#void msgpack_object_print(FILE* out, msgpack_object o);

#MSGPACK_DLLEXPORT
#bool msgpack_object_equal(const msgpack_object x, const msgpack_object y);

#/** @} */


#ifdef __cplusplus
#endif

#endif /* msgpack/object.h */


#typedef struct {
    #char *cur;       /* SvPVX (sv) + current output position */
    #const char *end; /* SvEND (sv) */
    #SV *sv;          /* result scalar */

    #bool prefer_int;
    #bool canonical;
#} enc_t;

#typedef struct msgpack_packer {
    #void* data;
    #msgpack_packer_write callback;
#} msgpack_packer;

    class msgpack_packer_write is repr('CPointer') {
    }

    #class msgpack_packer is repr('CStruct') {
        #has Pointer[void] $.data;
        ##has msgpack_packer_write $.callback;# = sub (Pointer[void] $data is rw, Str $buf, size_t $len) { say "called" };
        #has Pointer[void]  $.callback; is rw; #= sub ( Pointer[void] $data, Str $bur, size_t $len ) { say "plop";};
    #}

    class msgpack_packer is repr('CStruct') { has Pointer[void] $.data; has Pointer $.callback; }
    #class msgpack_packer is repr('CStruct') { has Pointer[void] $.data; has Pointer &.callback ( Pointer[void] $data, Str $bur, size_t $len ) {}; }

    sub libmsgpack { 'libmsgpackc.dylib' }

    #sub msgpack_pack_str( MsgPackData $data is rw, size_t $length --> int32 ) is native( &libmsgpack ) { * }

    sub msgpack_pack_object( msgpack_packer $data is rw, msgpack_object $obj --> int32 ) is native( &libmsgpack ) { * }

    #sub msgpack_pack_str_body() is native( &libmsgpack ) { * }
#}

    #typedef struct msgpack_packer { void* data; msgpack_packer_write callback; } msgpack_packer;

my $packer = msgpack_packer.new( );#callback => sub (Pointer[void] $data is rw, Str $buf, size_t $len) { say "called" } );
nativecast(:( Pointer[void] $data, Str $bur, size_t $len --> int32), $packer.callback );
#typedef int (*msgpack_packer_write)(void* data, const char* buf, size_t len);
#$data.callback = sub (Pointer[void] $data, Str $buf, size_t $len) { say "called" };
say "before serialization";

my $to_serialize = msgpack_object.new( type => MSGPACK_OBJECT_NIL );
say "will pack";
say msgpack_pack_object( $packer, $to_serialize );
#dd $data;
#msgpack_pack_str( $data, 3);
#msgpack_pack_nil( $data );
