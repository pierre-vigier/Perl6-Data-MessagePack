#include <stdio.h>
#include <msgpack.h>

void serialize_int( int i, msgpack_sbuffer* buffer ) {
       /*msgpack_sbuffer* buffer = msgpack_sbuffer_new();*/
       msgpack_packer* pk = msgpack_packer_new(buffer, msgpack_sbuffer_write);

       msgpack_sbuffer_clear(buffer);

       msgpack_pack_int(pk, i);

        /* cleaning */
        /*msgpack_sbuffer_free(buffer);*/
        /*msgpack_packer_free(pk);*/
       /*return buffer;*/

       /*msgpack_sbuffer sbuf;*/
    /*msgpack_packer pk;*/
    /*msgpack_zone mempool;*/
    /*msgpack_object deserialized;*/

    /*[> msgpack::sbuffer is a simple buffer implementation. <]*/
    /*msgpack_sbuffer_init(&sbuf);*/

    /*[> serialize values into the buffer using msgpack_sbuffer_write callback function. <]*/
    /*msgpack_packer_init(&pk, &sbuf, msgpack_sbuffer_write);*/

    /*msgpack_pack_array(&pk, 3);*/
    /*msgpack_pack_int(&pk, 1);*/
    /*msgpack_pack_true(&pk);*/
    /*msgpack_pack_str(&pk, 7);*/
    /*msgpack_pack_str_body(&pk, "example", 7);*/

    /*print(sbuf.data, sbuf.size);*/
}

void deserialize( char* data, size_t size, msgpack_object* obj ) {
    msgpack_unpacked msg;
    msgpack_unpacked_init(&msg);
    msgpack_unpack_next(&msg, data, size, NULL);
    obj = &msg.data;
    /*print(sbuf.data, sbuf.size);*/
    /*msgpack_object_print(stdout, o);  [>=> ["Hello", "MessagePack"] <]*/

    //printf( "\n\n\n %02x ", o.type );
    ////obj = o;

    printf( "\n\n\n %d ", obj->type );
}
void deserialize2( char* data, size_t size, msgpack_object_type* type ) {
    msgpack_unpacked msg;
    msgpack_unpacked_init(&msg);
    msgpack_unpack_next(&msg, data, size, NULL);
    msgpack_object o = msg.data;
    type = &o.type;
    /*print(sbuf.data, sbuf.size);*/
    /*msgpack_object_print(stdout, o);  [>=> ["Hello", "MessagePack"] <]*/

    /*printf( "\n\n\n %02x ", o.type );*/
    /*type = o.type;*/

    /*printf( "\n\n\n %d ", obj->type );*/
}

void test(void) {
        /* creates buffer and serializer instance. */
        msgpack_sbuffer* buffer = msgpack_sbuffer_new();
        msgpack_packer* pk = msgpack_packer_new(buffer, msgpack_sbuffer_write);

        int j;

        for(j = 0; j<23; j++) {
           /* NB: the buffer needs to be cleared on each iteration */
           msgpack_sbuffer_clear(buffer);

           /* serializes ["Hello", "MessagePack"]. */
           msgpack_pack_array(pk, 3);
           msgpack_pack_bin(pk, 5);
           msgpack_pack_bin_body(pk, "Hello", 5);
           msgpack_pack_bin(pk, 11);
           msgpack_pack_bin_body(pk, "MessagePack", 11);
           msgpack_pack_int(pk, j);

           /* deserializes it. */
           msgpack_unpacked msg;
           msgpack_unpacked_init(&msg);
           msgpack_unpack_next(&msg, buffer->data, buffer->size, NULL);

           /* prints the deserialized object. */
           msgpack_object obj = msg.data;
           msgpack_object_print(stdout, obj);  /*=> ["Hello", "MessagePack"] */
           puts("");
        }

        /* cleaning */
        msgpack_sbuffer_free(buffer);
        msgpack_packer_free(pk);
}
