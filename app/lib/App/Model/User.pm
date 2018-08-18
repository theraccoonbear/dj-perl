package App::Model::User;

use base qw(App::Model);

#use App::Schema:ResultSet::User;

our $must_have = ['username', 'password'];

sub create {
  my ($self, $params) = @_;
  my $missing = [grep { !defined $params->{$_} } @{$must_have}];
  if (scalar @{$missing}) {
    #return status_400 { missing => $missing };
    warn 'missing: ' . join(', ', @{$missing});
  }

  my $user = $self->schema->resultset('User')->create({
    username => $params->{'username'},
    pass_hash => bcrypt->crypt($params->{'password'})
  });

  return $user;
}
