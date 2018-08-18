#!/usr/bin/env perl
use strict;
use warnings;
use Data::Printer;

use lib '../lib';

use Crypt::Bcrypt::Easy;

use App::Schema;

p(%ENV);
p(@INC);

my $schema = App::Schema->connect(
	"dbi:Pg:dbname=$ENV{APP_DB_NAME};host=$ENV{APP_DB_HOST}",
  $ENV{APP_DB_USER},
  $ENV{APP_DB_PASSWORD},
  { AutoCommit => 1, RaiseError => 1, PrintError => 0}
);

#$schema->create_ddl_dir(['PostgreSQL'], '0.1', './dbscriptdir/');
#$schema->deploy();

#my @users = (['hanglighter', 'xxx'], ['another', 'zzz']);
my @users = map { {
  username => "hanglighter_$_",
  pass_hash => bcrypt->crypt("password$_")
} } (1..100);
$schema->populate('User', [
    [qw/username pass_hash/],
    @users,
]);
