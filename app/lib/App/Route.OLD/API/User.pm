package App::Route::API::User;
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

sub register_user {
	my $params = decode_json(request->body);

	if (!$params->{username}) {
		debug 'attempt to register without username';
		return api_error 'no username', 400;
	}
	
	if (!$params->{password}) {
		debug 'attempt to register without username';
		return api_error 'no password', 400;
	}

	if ($params->{username} !~ /^[A-Za-z0-9._-]+/xsm) {
		debug 'bad username attempted "' . $params->{username} . q{"};
		return api_error 'bad username', 400;
	}

	my $user = $user_model->get_by_username($params->{username});

	if ($user) {
		return api_error 'username unavailable', 409;
	}

	my $newuser = $auth->create({
		username => $params->{username},
		password => $params->{password},
		status => 'green'
	});
	my $new_user = $user_model->get($newuser->inserted_id);

	debug "$params->{username} not found so we created a new account";
	session 'username' => $params->{username};
	session 'user' => $new_user;
	var 'username' => $params->{username};
	return api_resp {
		user => $new_user
	};
}

sub delete_user {
	my $user_id = param 'user_id';
	my $user = $user_model->get($user_id);
	if (!$user) {
		return api_error 'user not found', 404;
	}

	# @toto For now only usernames matching this pattern, for test self-cleanup, are allowed
	if ($user->{username} !~ m/^__test-user-/xsm) {
		return api_error 'not authorized', 403;
	}

	$user_model->remove($user_id);

	debug "Deleted user $user_id";
	p($user);

	return api_success 'ok';
}

sub get_user {
	my $user_id = param 'user_id';
	my $user = $user_model->get($user_id);
	if (! $user) {
		return api_error 'user not found', 404;
	}
	delete $user->{password};

	return api_resp { user => $user };
}

sub update_user {
	my $user_id = param 'user_id';

	my $user = $user_model->get($user_id);
	if (! $user) {
		return api_error 'user not found', 404;
	}

	my $params = decode_json(request->body);

	# sanitize inputs; yes, it should be whitelisted
	map { delete $params->{$_} } qw( username password _id );

	my $result = $user_model->save($user_id, $params);

	$user = $user_model->get($user_id);
	session 'user' => $user;

	if (! $result->acknowledged) {
		return api_error 'update failed';
	}

	return api_resp {
		user => $user
	};
}

sub lookup_users {
	my $query = param 'query';
	my $matches = [];

	if ($query) {
		$matches = $user_model->find({
			username => qr/\Q$query\E/xsmi
		});
	}

	return api_resp {
		users => $matches
	};
}

prefix '/api/v1/:api_key' => sub {
	get '/users' => \&lookup_users;
	post '/users' => \&register_user;
	get '/users/:user_id' => \&get_user;
	del '/users/:user_id' => \&delete_user;
	# @todo auth middleware
	put '/users/:user_id' => \&update_user;
	# get '/races' => \&list;
	# get '/races/:race_id' => \&retrieve;
	# put '/races/:race_id' => \&update_race;
	# put '/races/:race_id/racer/:bib' => \&update_racer;
};



1;
