package App::Route::API::Friend;
use strict;
use warnings;

use App::Model::User;

use JSON::XS;
use Data::Printer;
use Dancer2 appname => 'hanglight';
use Dancer2::Plugin::API;
use Dancer2::Plugin::Auth;

our $VERSION = 0.1;

my $user_model = App::Model::User->instance();
my $follower_model = App::Model::Follower->instance();

sub list_friends {
	my $user = session 'user';
	my $friendships = $follower_model->find({
		follower => $follower_model->oid($user->{_id}->value)
	});

	# if you got no friends, at least claim yourself :)
	if (! scalar @{ $friendships }) {
		# @todo this is handy during testing, but needs to be removed
		$friendships = [{
			follower => $user_model->oid($user->{_id}->value),
			followee => $user_model->oid($user->{_id}->value)
		 }];
	}

	my $friends = $follower_model->resolve_followees($friendships);

	return api_resp {
		friends => $friends
	};
}

sub add_friend {
	my $user_id = param 'user_id';
	my $user = session 'user';

	my $friends = $follower_model->find({
		follower => $follower_model->oid($user->{_id}->value),
		followee => $follower_model->oid($user_id)
	});

	my $new_friend = $user_model->find($user_id);

	if (!$new_friend) {
		return api_error 'not found', 404;
	}

	if (scalar @{ $friends }) {
		return api_success 'ok';
	}

	my $resp = $follower_model->add({
		follower => $follower_model->oid($user->{_id}->value),
		followee => $follower_model->oid($user_id)
	});

	return api_success 'ok'
}

sub remove_friend {
	my $user_id = param 'user_id';
	my $user = session 'user';

	my $result = $follower_model->remove({
		follower => $follower_model->oid($user->{_id}->value),
		followee => $follower_model->oid($user_id)
	});
	if (!$result->acknowledged) {
		return api_error 'unable to remove friend';
	}

	return api_success 'ok';
}


prefix '/api/v1/:api_key' => sub {
	get '/friends' => require_logged_in \&list_friends;
	post '/friends/:user_id' => require_logged_in \&add_friend;
	del '/friends/:user_id' => require_logged_in \&remove_friend;
};



1;
