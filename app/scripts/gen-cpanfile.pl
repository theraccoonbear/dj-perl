#!/usr/bin/env perl
use strict;
use warnings;

use CPAN;
use Data::Printer;

sub requires {
  my ($mod, $version) = @_;
  my $mo = CPAN::Shell->expandany($mod);
  print "Checking for $mod... ";
  if ($mo) {
    my $our_version = $mo->inst_version;
    my $cpan_version = $mo->cpan_version;
    print "found $our_version (CPAN offers $cpan_version).\n";
    print STDERR <<_CPAN;
require "$mod", ">= $our_version"; # CPAN = $cpan_version;
_CPAN
  } else {
    print "NOT INSTALLED!\n";
  }
}


if (-f 'cpanfile') {
  require './cpanfile';
} else {
  print "No cpanfile found.  Run this script from the director it is located in.\n"
}
