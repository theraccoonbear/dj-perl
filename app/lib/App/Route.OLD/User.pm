package App::Route::User;

use strict;
use warnings;

use Dancer2 appname => 'hanglight';
use File::Slurp;
use App::Auth;
use Data::Printer;
use Data::Dumper;
use YAML::XS;
use File::Slurp;
use Crypt::Bcrypt::Easy;
use Digest::SHA qw(sha256_hex);


our $VERSION = 0.1;

my $users = App::Model::User->instance();
my $auth = App::Auth->new();

prefix '/user';

get '/login' => sub {
	if (session 'username') {
		say STDERR "already logged in as " . session 'username';
		redirect q{/};
	}
	return template 'user/login';
};

post '/login' => sub {
	my $params = request->body_parameters;

	if ($params->{username} && $params->{password}) {
		my $user = $users->get_by_username($params->{username});
		if ($user) {
			if ($auth->validateCredentials($params->{username}, $params->{password})) {
				debug "$params->{username} authenticated";
				session 'username' => $params->{username};
				session 'user' => $user;
				var 'username' => $params->{username};
				redirect q{/};
			}
			flash(error => 'invalid login');
			warn "$params->{username} failed authentication";
		} else {
			my $newuser = $auth->create({
				username => $params->{username},
				password => $params->{password},
				status => 'green'
			});
			debug "$params->{username} not found. created account.";
			flash(success => 'new user created!');
			session 'username' => $params->{username};
			session 'user' => $users->get($newuser->inserted_id);
			var 'username' => $params->{username};
			redirect q{/};
		}
	}

	template 'user/login', {

	};
};

get '/logout' => sub {
	session 'username' => undef;
	var 'username' => undef;
	redirect '/user/login';
};

1;
