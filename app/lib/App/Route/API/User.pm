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
  my $user;

  eval {
    $user = $user_m->create(body_parameters);
  };

  if ($@) {
    return status_400, { error => 1, message => $@ };
  }

  return status_created { status => 'ok', user => $user->TO_JSON };
}


1;
