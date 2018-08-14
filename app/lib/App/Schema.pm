package App::Schema;

use warnings;
use strict;

our $VERSION = 0.001;

use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_namespaces;

1;