package App::Model::Follower;
use strict;
use warnings;

our $VERSION = 0.1;

use MooseX::Singleton;

extends 'App::Model';

use Data::Printer;
use App::Model::User;

my $users = App::Model::User->instance();

has '+model_name' => (default => 'followers');

sub follow {
	my ($self, $follower, $followee) = @_;
	
	if (!$self->follows($follower, $followee)) {
		my $new_follow = {follower => $follower, followee => $followee};
		p($new_follow);
		$self->add($new_follow);
	}

	return;
}

sub resolve_followees {
	my ($self, $friends) = @_;
	
	my $lookups = {};
	foreach my $f (@{ $friends }) {
		$lookups->{$f->{followee}->value} = 1;
	}

	my $resolved = $users->sanitize_all($users->find({
		"_id" => { 
			'$in' => [ map { $users->oid($_ ) } keys %{ $lookups } ]
		} 
	}));
	
	return $resolved;
}

sub follows {
	my ($self, $follower, $followee) = @_;
	
	my $status = [$self->collection->find({follower => $follower, followee => $followee})->all()];

	say STDERR "$follower does" . ($status && scalar @{$status} > 0 ? '' : "n't") . " follow $followee";
	return $status && scalar @{$status} > 0;
}

sub who_follows {
	my ($self, $user) = @_;
	
	my @res = $self->collection->find({followee => $user})->all();
	return [map { $_->{follower} } @res ];
}

sub followed_by {
	my ($self, $user) = @_;
	
	my @res = $self->collection->find({follower => $user})->all();
	return [map { $users->get_by_username($_->{followee}) } @res ];
}


1;