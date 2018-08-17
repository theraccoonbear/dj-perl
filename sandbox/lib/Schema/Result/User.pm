package Schema::Result::User;

use warnings;
use strict;

use base qw( DBIx::Class::Core );

__PACKAGE__->table('user');

__PACKAGE__->add_columns(
  id => {
    data_type => 'integer',
    is_auto_increment => 1
  },
  username => {
    data_type => 'text',
    is_nullable => 0
  },
  pass_hash => {
    data_type => 'text',
    is_nullable => 0
  },
  light_status => {
    data_type => 'text',
    is_nullable => 0,
    default_value => 'red'
  }
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint([qw( username )]);

#__PACKAGE__->has_many('cds' => 'MyApp::Schema::Result::Cd', 'artistid');

1;
