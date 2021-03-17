#!/usr/bin/perl

=head1 NAME

pastebin.pl -- Start the pastebin web application

=head1 SYNOPSIS

  pastebin.pl daemon
  pastebin.pl help

=head1 DESCRIPTION

This program loads the pastebin web application, a L<Mojolicious> web
application. 

=head1 SEE ALSO

L<PASTEBIN>, L<Mojolicious>

=cut

use strict;
use warnings;
use File::Spec::Functions qw( catdir updir );
use FindBin ();
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../extlib/perl5";

$ENV{MOJO_HOME} //= catdir( $FindBin::Bin, updir() );

require Mojolicious::Commands;
Mojolicious::Commands->start_app('Pastebin');
