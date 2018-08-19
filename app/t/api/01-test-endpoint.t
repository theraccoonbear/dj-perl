#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Data::Printer;
use Test::Helper;

my $data = Test::Helper::api_get('test');
ok($data->{hello}, "has hello key");
cmp_ok($data->{hello}, 'eq', 'World!', 'hello, world!');

done_testing;
