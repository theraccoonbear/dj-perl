package App::Route::API::Session;

use Dancer2 appname => $ENV{APP_NAME};
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::REST;

use Data::Printer;
use Crypt::Bcrypt::Easy;


sub register {
  prefix '/api/v1' => sub {
    resource session =>
      create => \&create_session,
  };
}

sub create_session {
  my $must_have = ['username', 'password'];
  my $missing = [grep { !defined body_parameters->get($_) } @{$must_have}];
  if (scalar @{$missing}) {
    return status_400 { missing => $missing };
  }
  p($missing);

  my $user = schema->resultset('User')->create({
    username => body_parameters->get('username'),
    pass_hash => bcrypt->crypt(body_parameters->get('password'))
  });

  return status_201 { status => 'ok', user => $user->TO_JSON };
}


1;
