package Net::Lighthouse;
use Any::Moose;

our $VERSION = '0.01';
has ['account', 'email', 'password', 'token'] => (
    isa      => 'Str',
    is       => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Lighthouse - 


=head1 VERSION

This document describes Net::Lighthouse version 0.01


=head1 SYNOPSIS

    use Net::Lighthouse;

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

