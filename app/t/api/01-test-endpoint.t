#!/usr/bin/env perl
use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Cookies;
use IO::Socket::SSL;
use REST::Client;
use Data::Printer;
use Test::More;

my $ua_string = "DJ-REST-Tester/0.1 Mozilla AppleWebKit/537.4 (KHTML, like Gecko) Chrome/50 Safari/537.4";
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
p($ua);

my $client = REST::Client->new();
$client->setUseragent($ua);
p($client);
# $client->GET('http://example.com/dir/file.xml');
# print $client->responseContent();
  
#A host can be set for convienience
$client->setHost('https://localhost:5000');
$client->GET('/api/v1/test');
diag($client->responseContent());
# $client->PUT('/dir/file.xml', '<example>new content</example>');
# if( $client->responseCode() eq '200' ){
#     print "Updated\n";
# }
  