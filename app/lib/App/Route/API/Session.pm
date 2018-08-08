package App::Route::API::Session;
use strict;
use warnings;

use App::Model::User;

use JSON::XS;
use Data::Printer;
use App::Auth;
use Dancer2 appname => 'hanglight';
use Dancer2::Plugin::API;

our $VERSION = 0.1;

my $user_model = App::Model::User->instance();
my $auth = App::Auth->new();

sub login {
	my $params = decode_json(request->body);

	if (!$params->{username}) {
		return api_error 'no username', 400;
	}
	
	if (!$params->{password}) {
		return api_error 'no password', 400;
	}
	my $user = $user_model->get_by_username($params->{username});

	if (!$user) {
		debug "Attempt to login as non-existent: " . $params->{username};
		return api_error 'invalid credentials', 403;
	}
	
	if (!$auth->validateCredentials($params->{username}, $params->{password})) {
		debug "$params->{username} failed authentication";
		return api_error 'invalid credentials', 403;
	}

	
	debug $params->{username} . ' authenticated';
	session 'username' => $params->{username};
	session 'user' => $user;
	var 'username' => $params->{username};
	return api_success 'ok';
}

sub logout {
	app->destroy_session;

	return api_success 'ok';
}

sub session_status {
	say STDERR "WE ARE HERE!\n\n";
	#my $user = session 'user';
	
	# my $s = session;
	# my $cookies = request->cookies;
	# p($cookies);
	# p($s);
	# p($user);
	return api_resp {
		#logged_in => $user ? $user_model->sanitize($user) : JSON::false
		logged_in => JSON::false
	};
}


prefix '/api/v1/:api_key' => sub {
	post '/sessions/new' => \&login;
	del '/sessions' => \&logout;
	# @todo remove this -- for testing
	get '/sessions/logout' => \&logout;
	get '/sessions/status' => \&session_status;
	# get '/races' => \&list;
	# get '/races/:race_id' => \&retrieve;
	# put '/races/:race_id' => \&update_race;
	# put '/races/:race_id/racer/:bib' => \&update_racer;
};



1;
