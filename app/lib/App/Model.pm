package App::Model;

use strict;
use warnings;

use Moose;

our $VERSION = 0.1;

has 'dbic_schema' => (
  is => 'rw',
  isa => 'App::Schema'
);

sub schema {
  my ($self) = @_;
  unless ($self->dbic_shema) {
    $self->dbic_schema(App::Schema->connect(
      "dbi:Pg:dbname=$ENV{APP_DB_NAME};host=$ENV{APP_DB_HOST}",
      $ENV{APP_DB_USER},
      $ENV{APP_DB_PASSWORD},
      { AutoCommit => 1, RaiseError => 1, PrintError => 0}
    ));
  }

  return $self->dbic_schema || die;
} 

sub create {

}

1;
