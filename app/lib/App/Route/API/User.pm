package App::Route::API::User;

use Dancer2 appname => $ENV{APP_NAME};
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::REST;

use Data::Printer;
use Crypt::Bcrypt::Easy;

use App::Model::User;

my $user_m = App::Model::User->new();


sub register {
  prefix '/api/v1' => sub {
    resource user =>
      get => \&get_user,
      create => \&create_user,
      delete => sub {
        # delete user where id = params->{id}
      },
      update => sub {
        # update user with params->{user}
      };
  };
}

sub get_user {
  my @raw = schema->resultset('User')->find(params->{id});
  my $results = [map { $_->TO_JSON } grep { defined $_ } @raw];

  return status_200 $results;
}

sub create_user {
  my $user = $user_m->create(body_parameters);
  # my $must_have = ['username', 'password'];
  # my $missing = [grep { !defined body_parameters->get($_) } @{$must_have}];
  # if (scalar @{$missing}) {
  #   return status_400 { missing => $missing };
  # }

  # my $user = schema->resultset('User')->create({
  #   username => body_parameters->get('username'),
  #   pass_hash => bcrypt->crypt(body_parameters->get('password'))
  # });

  return status_created { status => 'ok', user => $user->TO_JSON };
}


1;
