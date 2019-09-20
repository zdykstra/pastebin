package Pastebin;

use Mojo::Base 'Mojolicious';
use Mojo::Util qw( sha1_sum );
use File::Path qw( make_path );
use File::Basename;
use Mojolicious::Types;
use Net::Subnet qw( subnet_matcher );
use Data::Dumper;

sub startup {
  my ($app) = @_;

  $app->moniker('pastebin');
  my $config = $app->plugin('Config');
  $app->plugin('RenderFile');

  $app->plugin(AccessLog => { log => '/usr/local/pastebin/log/access.log' });

  if ( $> == 0 ) {
    $app->plugin(
      SetUserGroup => {
        user  => $config->{SetUserGroup}{user},
        group => $config->{SetUserGroup}{group},
      }
    );
  }

  # 12GB uploads
  $ENV{MOJO_MAX_MESSAGE_SIZE} = 12884901888;

  my $r = $app->routes;

  $r->get(
    '/:prefix/:limiter/*' => [
      prefix  => [ 'uploads', 'onetime', 'static' ],
      limiter => [ 'public',  'private' ]
    ]
  )->to( controller => 'Routes', action => 'downloads' );
  $r->post('/upload')->to( controller => 'Routes', action => 'upload' )->name('upload');
  $r->get('/webify')->to( controller => 'Routes', action => 'webify' )->name('webify');
}

1;
