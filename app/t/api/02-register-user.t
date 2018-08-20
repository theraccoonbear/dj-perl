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
cmp_ok($data->{user}->{username}, 'eq', $new_user->{username}, 'created new user');
my $created_user = $data->{user};

$data = Test::Helper::api_post('user', $new_user, 400);

$data = Test::Helper::api_delete('user/' . $created_user->{id});

# ok($data->{hello}, "has hello key");
# cmp_ok($data->{hello}, 'eq', 'World!', 'hello, world!');

done_testing;
