package App::Route;

use strict;
use warnings;

use FindBin;
use Cwd qw(abs_path);

use Dancer2 appname => $ENV{APP_NAME};
#use App::Util qw(api_error api_resp);
use Data::Printer;
# use App::Model::User;
# use App::Model::Follower;
use Dancer2::Plugin::Flash;
use Dancer2::Plugin::DBIC;

use App::Route::API;

our $VERSION = 0.1;

# my $users = App::Model::User->instance();
# my $followers = App::Model::Follower->instance();

prefix undef;

get q{/} => sub {
	my $users = schema->resultset('User')->find({ 'username' => 'hanglighter' });
	p($users);
};

set serializer => 'JSON';

App::Route::API->register();

any qr{.*} => sub {
	return send_file 'index.html';

	status 'not_found';

	debug "Something went wrong: " . request->path_info;

	my $params = {};
	if (request->path_info =~ m{^/(?<model>[a-z]+[a-zA-Z0-9_-]+)(?:/(?<action>[a-z]+[a-zA-Z0-9_-]+)(?:/(?<id>[a-f0-9]{24}))?)?}xsm) {
		#say STDERR "Were you trying to: " . $+{action} . ' to the ' . $+{id} . ' of ' . $+{model};
		$params->{model} = $+{model};
		$params->{action} = $+{action};
		$params->{id} = $+{id};
	}

	template 'err/404', $params;
};

1;
