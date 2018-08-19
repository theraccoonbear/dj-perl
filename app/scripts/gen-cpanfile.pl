#!/usr/bin/env perl
use strict;
use warnings;

use CPAN;
use Data::Printer;

my @wanted_modules = ();
my $header_out;
my $last_base;

sub checkRequire {
  my ($mod, $version) = @_;
  my $mo = CPAN::Shell->expandany($mod);
  print "Checking for $mod... ";
  if ($mo) {
    (my $base = $mod) =~ s/^([^:]+).*$/$1/xsm;
    if ($last_base && $base ne $last_base) {
      print STDERR "\n";
    }
    $last_base = $base;
    my $our_version = $mo->inst_version;
    my $cpan_version = $mo->cpan_version;
    print "found $our_version (CPAN offers $cpan_version).\n";
    if (!$header_out) {
      print STDERR "# This cpanfile was auto-generated\n";
      $header_out = 1;
    }
    print STDERR "requires '$mod', '>= $our_version'; # CPAN offers $cpan_version;\n";
  } else {
    print "NOT INSTALLED!\n";
  }
}

sub requires {
  my ($mod, $version) = @_;
  push @wanted_modules, {
    mod_name => $mod,
    version => $version
  };
}

if (-f 'cpanfile') {
  require './cpanfile';
} else {
  print "No cpanfile found.  Run this script from the director it is located in.\n";
  die;
}

map {
  checkRequire($_->{mod_name}, $_->{version})
} sort {
  $a->{mod_name} cmp $b->{mod_name}
} @wanted_modules;
