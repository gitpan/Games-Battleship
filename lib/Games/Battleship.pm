# $Id: Battleship.pm,v 1.5 2003/08/26 01:04:56 gene Exp $

package Games::Battleship;
use vars qw($VERSION); $VERSION = '0.01';
use strict;
use Carp;
use lib 'lib';
use Games::Battleship::Player;

sub new {  # {{{
    my ($proto, %args) = @_;
    my $class = ref ($proto) || $proto;

    my $self = {
        type     => $args{type} || undef,
        player_1 => Games::Battleship::Player->new(
            name  => $args{player_1} || 'player_1',
            fleet => $args{fleet_1},
            dimensions => $args{dimensions_1},
        ),
        player_2 => Games::Battleship::Player->new(
            name  => $args{player_2} || 'player_2',
            fleet => $args{fleet_2},
            dimensions => $args{dimensions_2},
        ),
    };

    bless $self, $class;
    return $self;
}  # }}}

sub player {  # {{{
    my ($self, $name) = @_;
    my $player;

    # Step through each player...
    for (keys %$self) {
        next if $_ eq 'type';

        # Found if we are looking at the same player name or number
        # (currently restricted to 10 players) or key.
        if (($_ eq $name) || ($self->{$_}{name} eq $name) ||
            ($name =~ /^\d+$/ && $name eq substr $_, -1, 1)
        ) {
            # Set the player object to return.
            $player = $self->{$_};
            last;
        }
    }

    croak "No such player '$name'.\n" unless $player;
    return $player;
}  # }}}

sub play {  # {{{
    my ($self, %args) = @_;
    my $winner = 0;

    while (not $winner) {
        # Take a turn per player.
        for my $player (keys %$self) {
            next if $player eq 'type';
            next unless $player->{life};

            # Strike each opponent.
            for my $opponent (keys %$self) {
                next if $opponent eq 'type';
                next if $opponent->{name} eq $player->{name} ||
                    !$opponent->{life};
                $player->strike($opponent, $self->_get_coordinate);
            }
        }

        # Do we have a winner?
        my @alive = grep { $_->{life} } keys %$self;
        $winner = @alive == 1 ? shift @alive : undef;
    }

    return $winner;
}  # }}}

sub _get_coordinate {  # {{{
    my $self = shift;
    my ($x, $y);

    # Are we using a specific game type?
    if ($self->{type}) {
carp "Unimlemented feature.  RTFM please.\n";
#        if ($self->{type} eq 'text') {
#        }
#        elsif ($self->{type} eq 'cgi') {
#        }
    }
#    else {
        # No?  Okay, just return random coordinates, then.
        ($x, $y) = (
            rand($self->{dimensions} + 1),
            rand($self->{dimensions} + 1)
        );
#    }

    return $x, $y;
}  # }}}

1;

__END__

=head1 NAME

Games::Battleship - "You sunk my battleship!"

=head1 SYNOPSIS

  use Games::Battleship;

  $g = Games::Battleship->new(
      player_1 => 'Gene',
      player_2 => 'Aeryk',
  );

  # This method is handy, but only used in the test script.
  $player_obj = $g->player($name);
  $player_obj = $g->player($key);
  $player_obj = $g->player($number);

  $winner = $g->play;
  print "$winner->{name} wins!\n";

=head1 ABSTRACT

Battleship game implementation

=head1 DESCRIPTION

A C<Games::Battleship> object represents a battleship game with
players, fleets and playing grids.

No, I did not do this for a school assignment, but rather because I
played it one night with my friend, Aeryk, and decided that it might
be fun to implement.

NOTE: Currently, this module's C<play> feature is not especially 
functional for the sole reason that the game C<type> attribute does
not exist yet.  Please bear with me.  The next release will rock.

The game can definitely be played with by using the individual 
methods in the C<Games::Battleship*> modules.

Please see the distribution test script for working code.

=head1 PUBLIC METHODS

=over 4

=item B<new> [%ARGUMENTS]

=over 4

=item * player_1 => $STRING

=item * player_2 => $STRING

Specify the player names.  If not given, explicitly, "player_1" and 
"player_2" are used as the names, by default.

=item * type => text | cgi | gui

The type of game we are playing.  This argument is optional.  If not
given, a random coodinate is chosen based on the C<dimensions> 
attribute.

This argument is used by the C<_get_coordinate> method to properly 
request input of the coordinates.

For text (and curses), this is an interactive console request.  For 
CGI programs, this is a call to the C<CGI::param> method.

* I have not determined the most appropriate functionality for the 
C<gui> type, yet.  There are many many GUIs out there...

* NOTE: Currently, this argument is B<not> implemented, so don't get 
your hopes up just yet.  I will add this to the next release, and 
there will be happiness in the valley.

=back

=item B<play> [%ARGUMENTS]

  $winner = $g->play;

Take a turn for each player, striking all the opponents, until there
is only one player left alive.

Return the C<Games::Battleship::Player> object that is the game 
winner.

=item B<player> $STRING

  $player_obj = $g->player($name);
  $player_obj = $g->player($key);
  $player_obj = $g->player($number);

Return the C<Games::Battle::Player> object that matches the given 
name, key or number (where the key is a C<player_*> key of the
C<Games::Battleship> instance and the number is just the numeric part
of the key).

=back

=head1 PRIVATE METHODS

=over 4

=item B<_get_coordinate>

  ($x, $y) = $g->_get_coordinate;

Return a grid position (as integers).

=back

=head1 TO DO

Allow more than 2 players in the constuctor and add an C<add_player>
method.

Allow network play.

Keep pending games and personal scores in a couple handy text files.

Make a simple eg/ program with text.

Make an eg/ Curses program with colored text.

Make an eg/ CGI program both as text and with Imager.

Make an eg/ standalone GUI program too.

Enhance to include the features in Hasbro's "Advanced Mission Game":
(2) exocet missles fired from your aircraft carrier;
(1) tomahawk missle with a massive footprint fired from your battleship;
(2) apache missles fired from your destroyer;
(2) torpedoes fired from your sub;
(2) recon airplanes for surveillance;
sonar imaging from your sub.
This means implementing weapon and recon classes with name, quantity, 
footprint, etc.

=head1 SEE ALSO

L<Games::Battleship::Player>

C<http://www.hasbro.com/pl/page.viewproduct/product_id.9388/dn/default.cfm>

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003, Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
