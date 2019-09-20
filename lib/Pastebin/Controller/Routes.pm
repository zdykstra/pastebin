package Pastebin::Controller::Routes;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw( sha1_sum );
use Mojo::File qw( path );
use File::Basename;
use Mojolicious::Types;
use Net::Subnet qw( subnet_matcher );

sub webify {
  my $self        = shift;
  return $self->render( template => 'webify', format => 'txt' );
}

sub downloads {
  my $self = shift;

  # Throw people out if they're not whitelisted
  if ( $self->stash('limiter') eq 'private' ) {
    my $client_ip = $self->tx->original_remote_address;
    my $acl       = subnet_matcher( @{ $self->config('private_acl') } );
    unless ( $acl->($client_ip) ) {
      $self->render( text => "Unauthorized", status => 401 );
      return;
    }
  }

  my $file      = $self->req->url->path;
  my $remote_ua = $self->req->headers->user_agent;

  $file = $self->config('base') . $file;
  my ( $name, $path, $suffix ) = fileparse( $file, qr/\.[^.]*/ );

  unless ( -f $file ) {
    return $self->render(
      status => 404,
      text   => "File $name$suffix not found\n"
    );
  }

  my $mimetype = `/usr/bin/file -b --mime-type $file`;
  chomp($mimetype);
  my $size = -s $file;

  # just return the file if grabbed via the CLI
  if ( ( $remote_ua =~ m/(wget|curl|fetch|powershell|ansible-httpget)/i )
    || ( $size > $self->config('max_pp_size') ) )
  {
    $self->render_file(
      'filepath'      => $file,
      'content_type'  => $mimetype,
    );
  }

  else {
    # Render in the browser
    if ( ( $mimetype eq "application/pdf" )
      || ( $mimetype =~ m{image} )
      || ( $mimetype =~ m{html} )
      || ( $file =~ m{ansible.out} ) )
    {
      $self->render_file(
        'filepath'            => $file,
        'content_type'        => $mimetype,
        'content_disposition' => "inline"
      );
    }
    # Pretty print
    elsif ( $mimetype =~ m{text} ) {
      my $file_content = Mojo::File->new($file)->slurp;
      $self->stash( pretty => $file_content );
    }
    # Force a download
    else {
      $self->render_file(
        'filepath'      => $file,
        'content_type'  => $mimetype,
      );
    }
  }

  if ( $self->stash('prefix') eq 'onetime' ) {
    unlink $file;
  }
}

sub upload {
  my $self = shift;

  my $file     = $self->param('p');
  my $filename = $file->filename;

  my $hash =
    sha1_sum( $self->tx->original_remote_address . $self->tx->remote_port );

  my $path;

  if ( $self->param('o') ) {
    $path = $self->config('onetime'); 
  } else { 
    $path = $self->config('regular');
  }

  if ( $self->param('s') ) {
    $path = $path . $self->config('public') . $hash . '/';
  }
  else {
    $path = $path . $self->config('private') . $hash . '/';
  }


  Mojo::File->new( $self->config('base') . $path )->make_path;
  my $ondisk = $self->config('base') . $path . $filename;
  $file->move_to($ondisk);

  return $self->render(
    status => 200,
    text   => $self->config('url') . $path . $filename . "\n"
  );
}
1;
