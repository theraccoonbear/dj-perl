package App::API;

use FindBin;
use Cwd qw(abs_path);

#use lib abs_path("$FindBin::Bin/../../../lib");
#use lib abs_path("$FindBin::Bin/../../../modules/lib/perl5");


use Dancer2 appname => 'hanglight';
use File::Slurp;
use Data::Printer;
use Data::Dumper;
use YAML::XS;
use File::Slurp;
use Crypt::Bcrypt::Easy;
use Digest::SHA qw(sha256_hex);
use Dancer2::Plugin::API;
use Dancer2::Plugin::Auth;

# @todo add in that whole API key yadda yadda ;)

get '/api/v1/:api_key/protected' => require_logged_in sub {
	return api_resp { you => 'got it' };
};

post qr{/api.*}xsm => sub {
	debug "DANGER WILL ROBINSON!";
	status 'not_found';
	return api_error { error => 'not found' }, 404;
};

1;
