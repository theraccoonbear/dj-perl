package App::Route::API;


use Dancer2 appname => $ENV{APP_NAME};
use Data::Printer;
use JSON qw();

sub register {
  use Dancer2::Plugin::DBIC;
  use Dancer2::Plugin::REST;
  use App::Route::API::User;
  
  prepare_serializer_for_format;

  get '/api/v1/test' => sub {
  	{ hello => 'World!' };
  };

  App::Route::API::User->register();

  any qr{/api/v1/?.*} => sub {
  	status_404 { error => JSON::true, message => "not found" };
  };
}

1;
