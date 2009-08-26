package Net::Lighthouse::User;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
extends 'Net::Lighthouse';

# read only attr
has [qw/id avatar_url/] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
);

# read&write attr
has [qw/name job website/] => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub load {
    my $self = shift;
    validate_pos( @_, { type => SCALAR, regex => qr/^\d+$/ } );
    my $id  = shift;
    my $ua  = $self->ua;
    my $url = $self->base_url . '/users/' . $id . '.xml';
    my $res = $ua->get($url);
    if ( $res->is_success ) {
        $self->load_from_xml( $res->content );
    }
    else {
        die "try to get $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub load_from_xml {
    my $self = shift;
    validate_pos( @_,
        { type => SCALAR | HASHREF, regex => qr/^<\?xml|^HASH\(\w+\)$/ } );
    my $ref = $self->_translate_from_xml(shift);

    # dirty hack: some attrs are read-only, and Mouse doesn't support
    # writer => '...'
    for my $k ( keys %$ref ) {
        $self->{$k} = $ref->{$k};
    }
    return $self;
}

sub _translate_from_xml {
    my $self = shift;
    validate_pos( @_,
        { type => SCALAR | HASHREF, regex => qr/^<\?xml|^HASH\(\w+\)$/ } );
    my $ref = shift;
    $ref = XMLin($ref) unless ref $ref;
    %$ref =
      map { my $new = $_; $new =~ s/-/_/g; $new => $ref->{$_} } keys %$ref;
    for my $k ( keys %$ref ) {
        if ( ref $ref->{$k} eq 'HASH' ) {
            if ( $ref->{$k}{nil} && $ref->{$k}{nil} eq 'true' ) {
                $ref->{$k} = undef;
            }
            elsif ( defined $ref->{$k}{content} ) {
                $ref->{$k} = $ref->{$k}{content};
            }
            elsif ( keys %{ $ref->{$k} } == 0 ) {
                $ref->{$k} = '';
            }
            else {
                warn 'no idea how to handle ' . $ref->{$k};
            }
        }
    }
    return $ref;
}

sub update {
    my $self = shift;
    validate(
        @_,
        {
            name    => { optional => 1, type => SCALAR },
            job     => { optional => 1, type => SCALAR },
            website => { optional => 1, type => SCALAR },
        }
    );
    my %args = @_;

    for my $field (qw/name job website/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { user => \%args }, KeepRoot => 1 );
    my $ua  = $self->ua;
    my $url = $self->base_url . '/users/' . $self->id . '.xml';

    my $request = HTTP::Request->new( 'PUT', $url, undef, $xml );
    my $res = $ua->request($request);

    # the current server returns 302 moved temporarily even updated with
    # success
    if ( $res->is_success || $res->code == 302 ) {
        $self->load( $self->id );    # let's reload
        return 1;
    }
    else {
        die "try to PUT $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub memberships {
    my $self = shift;
}

1;

__END__

=head1 NAME

Net::Lighthouse::User - 

=head1 SYNOPSIS

    use Net::Lighthouse::User;

=head1 DESCRIPTION


=head1 INTERFACE



=head1 DEPENDENCIES


None.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
