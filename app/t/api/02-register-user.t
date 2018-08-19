#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Data::Printer;
use Test::Helper;


my $rnum = int(rand() * 100000);
my $new_user = {
  username => "testuser_$rnum",
  password => '0p$e'
};

my $data;

$data = Test::Helper::api_post('user', $new_user);
p($data);
cmp_ok($data->{username}, 'eq', $new_user->{username}, 'created new user');

$data = Test::Helper::api_post('user', $new_user, 400);

# ok($data->{hello}, "has hello key");
# cmp_ok($data->{hello}, 'eq', 'World!', 'hello, world!');

done_testing;
