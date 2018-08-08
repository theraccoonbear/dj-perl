package App::Model::Event;
use strict;
use warnings;

our $VERSION = 0.1;

use MooseX::Singleton;

extends 'App::Model';

use Data::Printer;
use App::Model::User;
use JSON;

has '+model_name' => (default => 'events');
has '+mongo_options' => (default => sub {
	return [
		capped => JSON::true,
		size => 100_000_000
	];
});

my $users = App::Model::User->instance();

# @todo get tailable cursors working
sub tail_find {
	my ($self, $cond) = @_;

	say STDERR "Getting tailed...";

	my $tailed = $self
		->collection()
		->find($cond)
		->tailable_await(1)
		->max_await_time_ms(100);
	#p($tailed);
	say STDERR "...OK";
	return $tailed;
}

sub event_monitor {
	my ($self, $user_id) = @_;
	return $self->tail_find({
		recipient => $self->oid($user_id),
		timestamp => {
			'$gte' => time
		}
	});
}



sub emit_event {
	my ($self, $username, $action, $data, $recipients) = @_;

	$action =~ s/[^A-Za-z_]+/_/xsm;
	my $event = {
		username => $username,
		action => $action,
		data => $data,
		recipients => $recipients,
		timestamp => time
	};
	# @todo: use this https://metacpan.org/pod/Hash::Sanitize

	return $self->add($event);
}


1;