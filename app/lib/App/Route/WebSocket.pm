package App::Route::WebSocket;
use strict;
use warnings;
our $VERSION = 0.1;
use utf8;

#use Dancer2 appname => 'hanglight';
use Plack::App::WebSocket;
use AnyEvent;
use AnyEvent::HTTP;
use Data::Printer;
use JSON::XS;
use List::Util qw(min max);
use App::Model::Event;
use App::Model::Session;
use App::Model::Follower;
use boolean;

my $events_model = App::Model::Event->instance();
my $users = App::Model::User->instance();
my $followers = App::Model::Follower->instance();
my $sessions = App::Model::Session->instance();
my $json = JSON::XS->new->ascii->pretty->allow_nonref->allow_blessed->convert_blessed;

sub to_app {

    say STDERR "WebSocket initializing...";

    my $ws_app = Plack::App::WebSocket->new(
        on_error => sub {
            my $env = shift;

			say STDERR "#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#";
            say STDERR "WebSocket error: " . $env->{"plack.app.websocket.error"};
			say STDERR "#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#=-=#";
            return [500,
                    ["Content-Type" => "text/plain"],
                    ["Error: " . $env->{"plack.app.websocket.error"}]];
        },
        on_establish => sub {
            my $conn = shift; ## Plack::App::WebSocket::Connection object
            my $env = shift;  ## PSGI env
            my $w;
            my $cookies = {map { split(/=/xsm) } split(/;\s*/xsm, $env->{HTTP_COOKIE} || q{})};
            my $session;
            my $user;
            
            say STDERR "WebSocket connecting...";
            if ($cookies->{'dancer.session'}) {
                say STDERR "Getting session " . $cookies->{'dancer.session'} . "...";
                $session = $sessions->get($cookies->{'dancer.session'});
                $user = $session->{data}->{user};
                say STDERR "Hello there $user->{username}!";
            }
            say STDERR "WebSocket established";
			say STDERR "Sending test event...";
			$events_model->add({
				recipient => $events_model->oid($user->{_id}->value),
				message => "Hello, World!"
			});


            $conn->on(
                message => sub {
                    my ($connection, $msg) = @_;
                    my $dat = decode_json($msg);

                    my $resp = {};
                    
                    if ($dat->{eventType}) {
                        say STDERR "WebSocket message: '" . $dat->{eventType} . "' from '" . $user->{username} . "'";
                        #p($dat);
                        if ($dat->{eventType} eq 'subscribe') {
                            say STDERR "Subscribing to messages";
                            $resp->{msg} = 'subscribed';
                            # @todo emit event with recipient specified
                            $resp->{payload} = {
                                events => [{
                                    eventType => 'subscribed',
                                    who => $user,
                                    data => {}
                                }]
                            };
                            my $seconds = 0.1;
                            my $last_event = time;
							
							say STDERR "Attemtping to get tailable event cursor";
							# my $event_cursor = $events_model->tail_find({
							# 	recipient => $events_model->oid($user->{_id}->value)
							# });
							my $event_cursor = $events_model->event_monitor($user->{_id}->value);
							say STDERR "Got cursor.";

                            $w = AnyEvent->timer(after => 0, interval => $seconds, cb => sub {
								#say STDERR "Checking for new events for " . $user->{username};
                                # my $new_events = $events_model->find({
                                #     timestamp => {
                                #         '$gt' => $last_event#,
                                #         #'recipients' => [$user->{username}] # @todo take this out of timestamp
                                #     },
                                # });

								my $new_events = [];
								while (my $event = $event_cursor->next) {
									push @{$new_events}, $event;
								}

								# $connection->send($json->encode({
								# 	payload => {
								# 		events => [$event]
								# 	},
								# 	now => time
								# }));

                                if (scalar @{$new_events} > 0) {
                                    $connection->send($json->encode({
                                        payload => {
                                            events => $new_events
                                        },
                                        now => time
                                    }));
                                    # my $old_last = $last_event;
                                    # foreach my $ev (@{$new_events}) {
                                    #     $last_event = max($last_event, $ev->{timestamp});
                                    # }
                                }
                            });
                        } elsif ($dat->{action} eq 'change_light') {
                            say STDERR "$user->{username} set status to $dat->{payload}->{color}";
                            $users->save($user->{_id}, { status => $dat->{payload}->{color}});
                            my $recipients = $followers->who_follows($user->{username});
                            my $payload = { 
                                username => $user->{username},
                                color => $dat->{payload}->{color}
                            };
                            $events_model->emit_event($user->{username}, 'change_light', $payload, $recipients);

                        }# elsif ($dat->{action} eq 'follow') {
                        #     say STDERR "$user->{username} wants to follow $dat->{payload}->{followee}";
                        #     $followers->follow($user->{username}, $dat->{payload}->{followee});
                        # } elsif ($dat->{action} eq 'location_update') {
                        #     say STDERR "$user->{username} is now located at $dat->{payload}->{latitude}, $dat->{payload}->{longitude}";
                        #     $users->save($user->{_id}, { location => $dat->{payload}});

                        #     my $recipients = $followers->who_follows($user->{username});
                        #     my $payload = { 
                        #         username => $user->{username},
                        #         location => $dat->{payload}
                        #     };
                        #     $events_model->emit_event($user->{username}, 'location_update', $payload, $recipients);
                        # } elsif ($dat->{action} eq 'get_user') {
                        #     my $u = $users->get_by_username($dat->{payload}->{username});
                        #     p($u);
                        #     my $payload = {
                        #         user => $u
                        #     };
                        #     p($payload);
                        #     $events_model->emit_event($user->{username}, 'user_info', $payload, [$user->{username}]);
                        # }
                    }
                    if ($resp->{msg}) {
                        $resp->{now} = time;
                        $connection->send($json->encode($resp));
                    }
                    return;
                },
                finish => sub {
                    undef $conn;
                    say STDERR "WebSocket finish occured";
                },
            );
            return $conn;
        }
    )->to_app;

    say STDERR "...WebSocket initialized";

    return $ws_app;
}

1;