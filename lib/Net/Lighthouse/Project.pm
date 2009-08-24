package Net::Lighthouse::Project;
use Any::Moose;
use Params::Validate ':all';
extends 'Net::Lighthouse';
# read only attr
has [
    qw/created_at default_assigned_user_id default_milestone_id description
      description_html hidden id open_ticket_count permalink
      send_changesets_to_events updated_at open_states_list closed_states_list
      open_states closed_states/
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

# read&write attr
# TODO access and license are not writable in official document,
# but the official ruby api are. let's make them writable for now
has [qw/archived access license name public/] => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub find {
    my $self = shift;
    validate_pos( @_, { type => SCALAR, regex => qr/^\d+$/ } );
    my $id = shift;
    my $ua = $self->ua;
    my $url = $self->base_url . '/projects/' . $id . '.xml';
    my $res = $ua->get( $url );
    if ( $res->is_success ) {
        use XML::Simple;
        my $ref = XMLin( $res->content );
        %$ref = map { my $old = $_; s/-/_/g; $_ => $ref->{$old} } keys %$ref;
        for my $k ( keys %$ref ) {
            if ( ref $ref->{$k} eq 'HASH' ) {
                if ( $ref->{$k}{nil} && $ref->{$k}{nil} eq 'true' ) {
                    $ref->{$k} = undef;
                }
                elsif ( defined $ref->{$k}{content} ) {
                    $ref->{$k} = $ref->{$k}{content};
                }
                else {
                    warn 'no idea how to handle ' . $ref->{$k};
                }
            }
        }
        return Net::Lighthouse::Project->new( %$ref );
    }
    else {
        die "try to get $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub save {
    my $self = shift;
}

sub tickets {
    my $self = shift;
}

1;

__END__

=head1 NAME

Net::Lighthouse::Project - 

=head1 SYNOPSIS

    use Net::Lighthouse::Project;

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

