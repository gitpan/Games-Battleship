# $Id: Craft.pm,v 1.1 2003/08/26 01:04:56 gene Exp $

package Games::Battleship::Craft;
use vars qw($VERSION); $VERSION = '0.01';
use strict;
use Carp;

sub new {  # {{{
    my ($proto, %args) = @_;
    my $class = ref ($proto) || $proto;

    croak "Craft name not provided.\n" unless defined $args{name};

    my $self = {
        id => $args{id},
        name => $args{name},
        hits => $args{hits} || 0,
        points => $args{points} || undef,
        position => $args{position} || undef,
    };

    # Default the id to the uppercased first char of name.
    $self->{id} = ucfirst substr $self->{name}, 0, 1
        unless defined $self->{id};

    bless $self, $class;
    return $self;
}  # }}}

sub hit {  # {{{
    my $self = shift;
    $self->{hits}++;
    return $self->{points} - $self->{hits};
}  # }}}

1;

__END__

=head1 NAME

Games::Battleship::Craft - A Battleship craft class

=head1 SYNOPSIS

  use Games::Battleship::Craft;

  $craft = Games::Battleship::Craft->new(
      id => 'T',
      name => 'tug boat',
      points => 1,
  )

  $points_remaining = $craft->hit;

=head1 ABSTRACT

A Battleship craft class

=head1 DESCRIPTION

A C<Games::Battleship::Craft> object represents a Battleship craft 
class.

=head1 PUBLIC METHODS

=over 4

=item B<new> %ARGUMENTS

=over 4

=item * id => $STRING

A scalar identifier to use to indicate position on the grid.  If one 
is not provided, the uppercased first name characer will be used by
default.

Currently, it is required that this be a single uppercase letter (the 
first letter of the craft name, probably), since a C<hit> will be 
indicated by "lowercasing" this mark on a player grid.

=item * name => $STRING

A required attribute provided to give the craft a name.

=item * points => $NUMBER

An attribute used to define the line segment span on the playing grid.

=item * position => [$X, $Y]

The position of the craft's "nose" on the grid.

=back

=item B<hit>

  $points_remaining = $craft->hit;

Increment the craft's C<hit> attribute value and return the 
difference between the C<points> and C<hit> attribute values.

=back

=head1 TO DO

Allow a craft to have a width.

=head1 SEE ALSO

L<Games::Battleship>

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003, Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
