package App::Model;

use strict;
use warnings;

use Moose;

use App::Schema;

our $VERSION = 0.1;

has 'model_name' => (
  is => 'rw',
  isa => 'Str'
);

has 'create_fields' => (
  is => 'rw',
  isa => 'ArrayRef[Str]',
  default => sub { [] }
);

has 'update_fields' => (
  is => 'rw',
  isa => 'ArrayRef[Str]',
  default => sub { [] }
);

my $dbic_schema;

sub schema {
  my ($self) = @_;
  unless ($dbic_schema) {
    $dbic_schema = App::Schema->connect(
      "dbi:Pg:dbname=$ENV{APP_DB_NAME};host=$ENV{APP_DB_HOST}",
      $ENV{APP_DB_USER},
      $ENV{APP_DB_PASSWORD},
      { AutoCommit => 1, RaiseError => 0, PrintError => 0}
    );
  }

  return $dbic_schema || die;
}

sub missing_fields {
  my ($self, $data, $is_update) = @_;

  return [grep { !defined $data->{$_} } @{
    $is_update ?
    $self->update_fields :
    $self->create_fields
  }];
}

sub create {
  my ($self, $params) = @_;
  
  my $missing = $self->missing_fields($params->{$_});
  if (scalar @{$missing}) {
    warn 'missing: ' . join(', ', @{$missing});
  }

  my $user = $self->schema->resultset($self->model_name)->create($params);

  return $user;
}
1;
