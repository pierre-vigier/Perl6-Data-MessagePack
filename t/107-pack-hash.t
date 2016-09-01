use v6;

use Test;
use Data::MessagePack;

plan 2;

ok Data::MessagePack::pack( { key => 'value' } ) ~~ Blob.new(129,163,107,101,121,165,118,97,108,117,101), "hash packed correctly";

ok Data::MessagePack::pack( { a => Any, b => [ 1.1 ], c => { aa => 3, bb => [] } } ) ~~ Blob.new(131,161,97,192,161,99,130,162,98,98,144,162,97,97,3,161,98,145,203,63,241,153,153,153,153,153,154), "hash packed correctly";
