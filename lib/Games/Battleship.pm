# $Id: Battleship.pm,v 1.22 2004/08/25 05:23:15 gene Exp $

package Games::Battleship;
$VERSION = 0.05;
use strict;
use warnings;
use Carp;
use Games::Battleship::Player;

sub new {
    my $proto = shift;
    my $class = ref ($proto) || $proto;
    my $self = {};
    bless $self, $class;
    $self->_init(@_);
    return $self;
}

sub _init {
    my ($self, @players) = @_;
    # Set up a default, two player game if no players are given.
    @players = ('', '') unless @players;
    $self->add_player($_) for @players;
}

sub game_type {
    my $self = shift;
    $self->{type} = shift if @_;
    return $self->{type};
}

sub add_player {
    my ($self, $player, $i) = @_;

    # If we are not given a number to use...
    unless ($i) {
        # ..find the least whole number that is not already used.
        my @nums = sort { $a <=> $b }
            grep { s/^player_(\d+)$/$1/ }
                keys %$self;
        my $n = 1;
        for (@nums) {
            last if $n > $_;
            $n++;
        }
        $i = $n;
    }

    # Make the name to use for our object.
    my $who = "player_$i";

    # Return undef if we are trying to add an existing player.
    if ( exists $self->{$who} ) {
        warn "A player number $i already exists\n";
        return;
    }

    # Set the player name unless we already have a player.
    $player = $who unless $player;

    # We are given a player object.
    if (ref ($player) eq 'Games::Battleship::Player') {
        $self->{$who} = $player;
    }
    # We are given the guts of a player.
    elsif (ref ($player) eq 'HASH') {
        $self->{$who} = Games::Battleship::Player->new(
            id => $player->{id} || $i,
            name => $player->{name} || $who,
            fleet => $player->{fleet},
            dimensions => $player->{dimensions},
        );
    }
    # We are just given a name.
    else {
        $self->{$who} = Games::Battleship::Player->new(
            id   => $i,
            name => $player,
        );
    }

    # Add the player object reference to the list of game players.
    push @{ $self->{players} }, $self->{$who};

    # Hand the player object back.
    return $self->{$who};
}

sub player {
    my ($self, $name) = @_;
    my $player;

    # Step through each player...
    for (keys %$self) {
        next unless /^player_/;

        # Are we looking at the same player name, key or number?
        if( $_ eq $name ||
            $self->{$_}{name} eq $name ||
            $self->{$_}{id} eq $name
        ) {
            # Set the player object to return.
            $player = $self->{$_};
            last;
        }
    }

    warn "No such player '$name'\n" unless $player;
    return $player;
}

sub players { return shift->{players} }

sub play {
    my ($self, %args) = @_;
    my $winner = 0;

    while (not $winner) {
        # Take a turn per live player.
        for my $player (@{ $self->{players} }) {
            next unless $player->{life};

            # Strike each opponent.
            for my $opponent (@{ $self->{players} }) {
                next if $opponent->{name} eq $player->{name} ||
                    !$opponent->{life};

                my $res = -1;  # "duplicate strike" flag.
                while ($res == -1) {
                    $res = $player->strike(
                        $opponent,
                        $self->_get_coordinate($opponent)
                    );
                }
            }
        }

        # Do we have a winner?
        my @alive = grep { $_->{life} } @{ $self->{players} };
        $winner = @alive == 1 ? shift @alive : undef;
    }

warn $winner->name ." is the winner!\n";
    return $winner;
}

# Return a coordinate from a player's grid.
sub _get_coordinate {
    my ($self, $player) = @_;

    my ($x, $y);

    # Are we using a specific game type?
    if ($self->{type}) {
warn "Unimlemented feature.  RTFM please.\n";
#        if ($self->{type} eq 'text') {}
#        elsif ($self->{type} eq 'cgi') {}
    }
#    else {
        # No?  Okay, just return random coordinates, then.
        ($x, $y) = (
            int 1 + rand $player->{grid}->{dimension}[0],
            int 1 + rand $player->{grid}->{dimension}[1]
        );
#    }

#    warn "$x, $y\n";
    return $x, $y;
}

1;

__END__

=head1 NAME

Games::Battleship - "You sunk my battleship!"

=head1 SYNOPSIS

  use Games::Battleship;

  $g = Games::Battleship->new(qw( Gene Aeryk ));
  $g->add_player('Stephanie');
  $winner = $g->play();
  print $winner->name(), " wins!\n";

  @player_objects = @{ $g->players };

  $player_obj = $g->player('Professor Snape');

=head1 DESCRIPTION

A C<Games::Battleship> object represents a battleship game between
players.  Each has a fleet of vessles and operates with a pair of
playing grids  One is for their own fleet and one for where the
enemy has been seen.

Everything is an object with default but mutable attributes.  This way
games can have two or more players each with a single fleet of custom
vessles.  These vessles are pretty simple and standard right now...

A game can be played with the handy C<play()> method or for finer
control, use individual methods of the C<Games::Battleship::*>
modules.  See the distribution test script for working code examples.

=head2 WHY?

I played this with my friends, Aeryk and Stepanie, and decided that it
would be a fun challenge to automate with line segment geometry.

=head1 PUBLIC METHODS

=over 4

=item B<new>

  $g = Games::Battleship->new;
  $g = Games::Battleship->new(
      $name_1,
      $player_object,
      { name => $name_2,
        fleet => \@fleet,
        dimensions => [ $width, $height ], },
  );

Construct a new C<Games::Battleship> object.

The players can be given as scalars, a C<Games::Battleship::Player>
object or as a hash reference containing meaningful object attributes.

If not given explicitly, 'player_1' and 'player_2' are used as the
player names and two 10x10 grids with 5 predetermined ships are setup
by default for each.

See L<Games::Battleship::Player> for details on the default and custom
settings.

=item B<add_player>

  $g->add_player;
  $g->add_player($name);
  $g->add_player({
      name => $name,
      fleet => \@fleet,
      dimensions => [$w, $h],
  });
  $g->add_player($player, $number);

Add a player to the existing game.

This method can accept either nothing, a string, a
C<Games::Battleship::Player> object or a hash reference
of meaningful C<Games::Battleship::Player> attributes.

This method also accepts an optional numeric second argument that is
the player number.

If this number is not provided, the least whole number that is not
represented in the player IDs is used.  If a player already exists
with that number, a warning is emitted and the player is not added..

=item B<play>

  $winner = $g->play;

Take a turn for each player, striking all the opponents, until there
is only one player left alive.

Return the C<Games::Battleship::Player> object that is the game
winner.

=item B<player>

  $player_obj = $g->player($name);
  $player_obj = $g->player($number);
  $player_obj = $g->player($key);

Return the C<Games::Battle::Player> object that matches the given
name, key or number (where the key is C</player_\d+/> and the number
is just the numeric part of the key).

=back

=head1 PRIVATE METHODS

=over 4

=item B<_get_coordinate>

  ($x, $y) = $g->_get_coordinate;

Return a grid position.

Currently this returns a random integer pair with the player grid
dimensions as the maximum.

Eventually this method will honor a game type attribute to allow
different interfaces such as CGI, Curses, Win32, etc. to get the
coordinate from the players interactively.

=back

=head1 TO DO

Implement the "number of shots" measure.  This may be based on life
remaining, shots taken, hits made or ships sunk (etc?).

Make the C<play> method output the player grids for each turn.

Keep pending games and personal scores in a couple handy text files.

Make an eg/simple program with text and then one with colored text.

Implement game type and then allow network play.

Make an eg/cgi program both as text and with Imager.

Make standalone GUI programs too...

Enhance to include these features:
sonar imaging from your submarine.
2 exocet missles fired from your aircraft carrier.
1 tomahawk missle fired from your battleship.
2 apache missles fired from your destroyer.
2 torpedoes fired from your submarine.
2 recon airplanes for surveillance.

This all just means implementing weapon and recon classes with name,
quantity and footprint.

=head1 SEE ALSO

L<Games::Battleship::Player>,
L<Games::Battleship::Craft>,
L<Games::Battleship::Grid>

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2003-2004, Gene Boggs

=head1 LICENSE

This software is free to use for non-commercial, personal purposes.

=cut
