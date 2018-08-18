package App;

use strict;
use warnings;

use Dancer2 appname => $ENV{APP_NAME};

use App::Route;

App::Route->register();

1;
