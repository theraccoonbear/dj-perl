package App::Model::User;
use strict;
use warnings;

our $VERSION = 0.1;

use MooseX::Singleton;

extends 'App::Model';

use Data::Printer;

has '+model_name' => (default => 'users');

has '+private_fields' => (
	default => sub {
		return {
			'password' => 1
		};
	}
);

sub get_by_username {
	my ($self, $username) = @_;
	
	my $user = [$self->collection->find({username => $username})->all()];

	return $user ? $user->[0] : undef;
}

sub user_exists {
	my ($self, $username) = @_;
	
	my $user = [$self->collection->find({username => $username})->all()];

	return $user ? $user->[0] : undef;
}

1;