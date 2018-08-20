package App::Model::User;

use Moose;

extends 'App::Model';

use Crypt::Bcrypt::Easy;

#use App::Schema:ResultSet::User;

#our $must_have = ['username', 'password'];

has '+create_fields' => (
  default => sub { ['username', 'password'] }
);

has '+model_name' => ( default => 'User' );

sub create {
  my ($self, $params) = @_;
  my $missing = $self->missing_fields($params->{$_});
  if (scalar @{$missing}) {
    warn 'missing: ' . join(', ', @{$missing});
  }

  my $user = $self->schema->resultset($self->model_name)->create({
    username => $params->{'username'},
    pass_hash => bcrypt->crypt($params->{'password'})
  });

  return $user;
}

1;
