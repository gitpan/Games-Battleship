package Games::Battleship::Grid;

use vars qw($VERSION);
$VERSION = '0.0201';

use strict;
use Carp;
use Games::Battleship::Craft;

sub new {  # {{{
    my ($proto, %args) = @_;
    my $class = ref ($proto) || $proto;
    my $self = {
        dimension => $args{dimension} || [9, 9],
    };
    bless $self, $class;
    $self->_init($args{fleet});
    return $self;
}  # }}}

# Place the array reference of craft on the grid.
sub _init {  # {{{
    my ($self, $fleet) = @_;

    # Initialize the matrix.
    for my $i (0 .. $self->{dimension}[0]) {
        for my $j (0 .. $self->{dimension}[1]) {
            $self->{matrix}[$i][$j] = '.';
        }
    }

    # Place the fleet on the grid.
    for my $craft (@$fleet) {
        my ($ok, $x0, $y0, $x1, $y1, $orient);

        if (defined $craft->{position}) {
            ($x0, $y0) = ($craft->{position}[0], $craft->{position}[1]);

            # Set the craft orientation and tail coordinates.
            ($orient, $x1, $y1) = _tail_coordinates(
                $x0, $y0,
                $craft->{points} - 1
            );
        }
        else {
            while (not $ok) {  # {{{
                $x0 = int(rand($self->{dimension}[0] + 1));
                $y0 = int(rand($self->{dimension}[1] + 1));

                # Set the craft orientation and tail coordinates.
                ($orient, $x1, $y1) = _tail_coordinates(
                    $x0, $y0,
                    $craft->{points} - 1
                );

                # If the craft is not placed off the grid and it does
                # not collide with another craft, then we are ok to
                # move on.
                if ($x1 <= $self->{dimension}[0] &&
                    $y1 <= $self->{dimension}[1]
                ) {
                    # For each craft with a position set that is not
                    # the current one, do the craft share a common
                    # point?
                    my $collide = 0;

                    for (@$fleet) {
                        # Ships are not the same.
                        if ($craft->{name} ne $_->{name}) {
                            # Ships don't intersect.
                            if (defined $_->{position} &&
                                _segment_intersection(
                                    $x0, $y0,
                                    $x1, $y1,
                                    @{ $_->{position}[0] },
                                    @{ $_->{position}[1] }
                                )
                            ) {
                                $collide = 1;
                                last;
                            }
                        }
                    }

                    $ok = 1 unless $collide;
                }
            }  # }}}

            # Set the craft position.
            $craft->{position} = [[$x0, $y0], [$x1, $y1]];
        }
#carp "$craft->{name}: [$x0, $y0], [$x1, $y1], $craft->{points}\n";

        # Add the craft to the grid.
        for my $n (0 .. $craft->{points} - 1) {
            if ($orient) {
                $self->{matrix}[$x0 + $n][$y0] = $craft->{id};
            }
            else {
                $self->{matrix}[$x0][$y0 + $n] = $craft->{id};
            }
        }
    }
}  # }}}

# Get the coordinates of the end of the segment based on a given span.
sub _tail_coordinates {  # {{{
    my ($x0, $y0, $span) = @_;

    # Set orientation to 0 (vetical) or 1 (horizontal).
    my $orient = int rand 2;
    
    my ($x1, $y1) = ($x0, $y0);

    if ($orient) {
        $x1 += $span;
    }
    else {
        $y1 += $span;
    }

    return $orient, $x1, $y1;
}  # }}}

sub _segment_intersection {  # {{{
    # 0 - Intersection dosn't exist.
    # 1 - Intersection exists.
    # 0 (2) - two line segments are parallel
    # 0 (3) - two line segments are collinear, but not overlap.
    # 4 - two line segments are collinear, and share one same end point.
    # 5 - two line segments are collinear, and overlap.

    croak "segment_intersection needs 4 points\n" unless @_ == 8;
    my (
        $x0, $y0,  $x1, $y1,  # AB segment 1
        $x2, $y2,  $x3, $y3   # CD segment 2
    ) = @_;
#carp "[$x0, $y0]-[$x1, $y1], [$x2, $y2]-[$x3, $y3]\n";

    my $xba = $x1 - $x0;
    my $yba = $y1 - $y0;
    my $xdc = $x3 - $x2;
    my $ydc = $y3 - $y2;
    my $xca = $x2 - $x0;
    my $yca = $y2 - $y0;

    my $delta = $xba * $ydc - $yba * $xdc;
    my $t1 = $xca * $ydc - $yca * $xdc;
    my $t2 = $xca * $yba - $yca * $xba;

    if ($delta != 0) {
        my $u = $t1 / $delta;
        my $v = $t2 / $delta;

        # Two segments intersect (including intersect at end points).
        if ($u <= 1 && $u >= 0 && $v <= 1 && $v >= 0) {
            return 1;
        }
        else {
            return 0; 
        }
    }
    else {
        # AB & CD are parallel.
#        return 2 if $t1 != 0 && $t2 != 0;
        return 0 if $t1 != 0 && $t2 != 0;

        # When AB & CD are collinear...
        my ($a, $b, $c, $d);

        # If AB isn't a vertical line segment, project to x-axis.
        if ($x0 != $x1) {
            # < is min, > is max
            $a = $x0 < $x1 ? $x0 : $x1;
            $b = $x0 > $x1 ? $x0 : $x1;
            $c = $x2 < $x3 ? $x2 : $x3;
            $d = $x2 > $x3 ? $x2 : $x3;

            if ($d < $a || $c > $b) {
                return 0;#3;
            }
            elsif ($d == $a || $c == $b) {
                return 4;
            }
            else {
                return 5;
            }
        }
        # If AB is a vertical line segment, project to y-axis.
        else {
            # < is min, > is max
            $a = $y0 < $y1 ? $y0 : $y1;
            $b = $y0 > $y1 ? $y0 : $y1;
            $c = $y2 < $y3 ? $y2 : $y3;
            $d = $y2 > $y3 ? $y2 : $y3;

            if ($d < $a || $c > $b) {
                return 0;#3;
            }
            elsif ($d == $a || $c == $b) {
                return 4;
            }
            else {
                return 5;
            }
        }
    }
}  # }}}

1;

__END__

=head1 NAME

Games::Battleship::Grid - A Battleship grid class

=head1 SYNOPSIS

  use Games::Battleship::Grid;

  $grid = Games::Battleship::Grid->new(
      fleet => \@fleet,
      dimension => [$width, $height],
  );

=head1 ABSTRACT

A Battleship grid class

=head1 DESCRIPTION

A C<Games::Battleship::Grid> object represents a Battleship grid 
class.

Check out the powerful and mathematically elegant 
C<_segment_intersection> function in the source code of this module.

=head1 PUBLIC METHODS

=over 4

=item B<new> %ARGUMENTS

=over 4

=item * fleet => [$CRAFT_1, $CRAFT_2, ... $CRAFT_N]

Array reference of an unlimited number of C<Games::Battleship::Craft> 
objects.

If provided, the fleet will be placed on the grid.  It is required 
that the number of ships and their combined sizes be less than the 
area of the grid.

=item * dimensions => [$WIDTH, $HEIGHT]

Array reference with the grid height and width values.

=back

=back

=head1 PRIVATE METHODS AND FUNCTIONS

=over 4

=item B<_init> [$CRAFT_1, $CRAFT_2, ... $CRAFT_N]

Initialize the grid with the C<Games::Battleship::Craft> object 
dimensions.

If an array reference of craft objects is provided, place them on the
grid so that they do not intesect (overlap or touch).

=item B<_tail_coordinates> @COORDINATES, $SPAN

  ($orientation, $x1, $y1) = _tail_coordinates($x0, $y0, $span);

Return the vertical or horizontal line segment orientation and the
tail coordinates, based on the head coodinates and a span (the length
of the segment).

Note that this routine is a function, not an object method.

=item B<_segment_intersection> @COORDINATES

  $intersect = _segment_intersection(
      px0, py0, px1, py1,
      qx0, qy0, qx1, qy1
  );

Return zero if there is no intersection (or touching or overlap).

Each pair of values define a coordinate and each pair of coordinates 
define a line segment.

=back

=head1 TO DO

Allow diagonal craft placement.

Allow some type of interactive craft repositioning.

Allow placement restriction rules (e.g. not on edges, not adjacent, 
etc.).

Allow > 2D playing spaces.

=head1 SEE ALSO

L<Games::Battleship>

L<Games::Battleship::Craft>

C<http://www.meca.ucl.ac.be/~wu/FSA2716/Exercise1.htm>

=head1 CVS

$Id: Grid.pm,v 1.11 2004/02/05 09:20:23 gene Exp $

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003, Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
