package App::Route::API;

use FindBin;
use Cwd qw(abs_path);

#use lib abs_path("$FindBin::Bin/../../../lib");
#use lib abs_path("$FindBin::Bin/../../../modules/lib/perl5");


use Dancer2 appname => $ENV{APP_NAME};
# use File::Slurp;
use Data::Printer;
# use Data::Dumper;
# use YAML::XS;
# use File::Slurp;
# use Crypt::Bcrypt::Easy;
# use Digest::SHA qw(sha256_hex);
# use Dancer2::Plugin::API;
# use Dancer2::Plugin::Auth;

use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::REST;

# @todo add in that whole API key yadda yadda ;)

prepare_serializer_for_format;

get '/api/v1/user.old/:username.:format' => sub {
	p(params->{username});
	debug 'Are we here?';
	my @raw = schema->resultset('User')->find({ 'username' => params->{'username'} });
	p(@raw);
	my $results = [map { { id => $_->id, username => $_->username, password => $_->pass_hash } } @raw ];

	p($results);
	return $results;
};

prepare_serializer_for_format;

prefix '/api/v1' => sub {
  resource user =>
    get    => sub {
      #{ hello => 'world' };
      # return user where id = params->{id}
      my @raw = schema->
        resultset('User')->
        find(params->{id});
      p(@raw);
      my $results = [map {
        { id => $_->id, username => $_->username, password => $_->pass_hash }
      } grep {
        defined $_
      } @raw];

      p($results);
      return $results;
    },
    create => sub { 
      # create a new user with params->{user}
    },
    delete => sub {
      # delete user where id = params->{id}
    },
    update => sub {
      # update user with params->{user}
    };
};


# get '/api/v1/:api_key/protected' => require_logged_in sub {
# 	return api_resp { you => 'got it' };
# };

# post qr{/api.*}xsm => sub {
# 	debug "DANGER WILL ROBINSON!";
# 	status 'not_found';
# 	return api_error { error => 'not found' }, 404;
# };

1;
