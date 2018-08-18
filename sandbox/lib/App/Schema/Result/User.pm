package App::Schema::Result::User;

use warnings;
use strict;

our $VERSION = 0.001;

use base qw( DBIx::Class::Core );

__PACKAGE__->table('users');

__PACKAGE__->add_columns(
  id => {
    data_type => 'integer',
    is_auto_increment => 1
  },
  username => {
    data_type => 'text',
  },
  pass_hash => {
    data_type => 'text',
  },
  light_status => {
    data_type => 'text',
    default_value => 'red'
  }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint([qw( username )]);

#__PACKAGE__->has_many('cds' => 'MyApp::Schema::Result::Cd', 'artistid');

1;
