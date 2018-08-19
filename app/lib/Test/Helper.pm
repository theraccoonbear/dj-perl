package Test::Helper;

use strict;
use warnings;

our $VERSION = 0.1;

use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Request::Common;
use Data::Printer;
use IO::Socket::SSL qw();
use JSON::XS;
use Digest::MD5 qw(md5_hex);
use Test::More;

my $dirty_env = {};

my $ua_string = "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4";
my $cookie_jar = HTTP::Cookies->new(
	file => "/tmp/lwp_cookies.dat",
	autosave => 1
);

my $ua = LWP::UserAgent->new(
	autocheck => 0,
	cookie_jar => $cookie_jar,
	SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE,
	PERL_LWP_SSL_VERIFY_HOSTNAME => 0,
	verify_hostname => 0,
	ssl_opts => {
		verify_hostname => 0
	}
);

my $config = {};

sub configure {
  my ($self, $cfg) = @_ || {};
  map {
    $config->{$_} = $cfg->{$_}
  } keys %{$cfg};
}


sub get_user_agent {
	return $ua;
}

sub get_cookie_jar {
	return $cookie_jar;
}

sub new_user {
	my $ep_reg = Test::Helper::endpoint('/users');

	my $header = ['Content-Type' => 'application/json'];

	my $username = '__test-user-' . time . int(rand() * 10_000); 
	my $password = int(rand() * 1_000_000);

	my $data = {
		username => $username,
		password => $password
	};

	my $encoded_data = encode_json($data);
	
	my $r = HTTP::Request->new('POST', $ep_reg, $header, $encoded_data);
	my $res  = $ua->request($r);

	if (! $res->is_success) {
		return;
	}
	my $body = decode_json $res->content;

	# this is useful to the tester
	$body->{user}->{password} = $password;
 	return $body->{user};
}

sub cleanup_user {
	my ($user) = @_;
	my $ep_del = Test::Helper::endpoint('/users/' . $user->{_id}->{'$oid'});

	my $r = HTTP::Request->new('DELETE', $ep_del);
	my $res  = $ua->request($r);

	if ($res->is_success) {
		return 1;
	}
	return;
}

sub url {
	my ($path) = @_;
	my $hostname = $config->{HOSTNAME} || $ENV{HOSTNAME} || 'localhost';
	my $port = $config->{PORT} || $ENV{PORT} || 5000;
	my $proto = $config->{PROTO} || $ENV{PROTO} || 'https';

	return "${proto}://${hostname}:${port}${path}";
}

sub endpoint {
	my ($action) = @_;

	return Test::Helper::url("/api/v1/${action}");
}

sub api_request {
  my ($req, $expected) = @_;
  my $resp_data;
  my $res;
  $expected ||= qr/2\d{2}/xsm;

  eval {
    $res = $ua->request($req);
    # p($req); p($res);
    if (ref $expected eq 'Regexp') {
      like($res->code, $expected, "received expected " . $res->code);
    } else {
      cmp_ok($res->code, 'eq', $expected, "received " . $res->code . "; expected $expected response");
    }
    
    if ($res->is_success) {
      $resp_data = decode_json($res->content);
    }
  };

  if ($res && $res->is_success) {
    ok(!$@, 'response data decoded');
  }
  return $resp_data;
}

sub api_get {
  my ($action, $expected) = @_;
  my $get = GET Test::Helper::endpoint($action);
  my $resp_data = Test::Helper::api_request($get, $expected);
  return $resp_data
}

sub api_post {
  my ($action, $data, $expected) = @_;
  $data = {} unless $data;

  my $header = ['Content-Type' => 'application/json'];
	my $encoded_data = encode_json($data);
	
	my $post = HTTP::Request->new('POST', Test::Helper::endpoint($action), $header, $encoded_data);

  my $resp_data = Test::Helper::api_request($post, $expected);
  return $resp_data
}

# sub env_key {
# 	my ($name) = @_;
# 	return $name;
# 	#return return  '__perl_test_' . md5_hex($name);
# }

# sub set_env {
# 	my ($name, $value) = @_;
# 	my $k = Test::Helper::env_key($name);
# 	if (! defined $ENV{$k}) {
# 		$dirty_env->{$k} = 1;
# 	}
# 	return $ENV{$k} = $value;
# }

# sub get_env {
# 	my ($name, $default, $no_set) = @_;
# 	my $k = Test::Helper::env_key($name);
# 	if (! defined $ENV{$k} && ! $no_set) {
# 		Test::Helper::set_env($name, $default);
# 	}
# 	return $ENV{$k} || $default;
# }

# sub clean_env {
# 	map { delete $ENV{$_} } keys %{ $dirty_env };
# 	return;
# }

1;
