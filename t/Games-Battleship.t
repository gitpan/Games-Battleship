BEGIN {
    use strict;
    use Test::More tests => 15;
    use_ok 'Games::Battleship';
}

my $obj = eval {
    Games::Battleship->new;
};
#print "$@\n";
isa_ok $obj, 'Games::Battleship', 'with no arguments';

$obj = Games::Battleship->new('gene', 'aeryk');
isa_ok $obj, 'Games::Battleship', 'with named players';

my $stephi = $obj->add_player('stephi');
isa_ok $stephi, 'Games::Battleship::Player', 'stephi';
is $stephi->{id}, 3, 'add_player without id number';

my $gene  = $obj->player('gene');
my $aeryk = $obj->player('aeryk');
my $steph = $obj->player('stephi');
isa_ok $steph, 'Games::Battleship::Player', 'by name';
isa_ok $obj->player('player_1'), 'Games::Battleship::Player', 'by key';
isa_ok $obj->player(1), 'Games::Battleship::Player', 'by number';

my $craft = $aeryk->craft(id => 'A');
isa_ok $craft, 'Games::Battleship::Craft', 'by id';
isa_ok $aeryk->craft(name => 'aircraft carrier'), 'Games::Battleship::Craft', 'by name';
ok $craft->hit == $craft->{points} - 1, 'craft hit';

my $strike = $aeryk->strike($gene, 0, 0);
ok $strike == 0 || $strike == 1, 'aeryk strikes gene at 0,0';
$strike = $aeryk->strike($gene, 0, 0);
is $strike, -1, 'duplicate strike';

ok length ($gene->grid), 'gene grid';
ok length ($aeryk->grid($gene)), 'aeryk grid';

__END__
print join "\n", (
    $gene->grid,
    '~',
    "Player: Aeryk, Opponent: Gene",
    $aeryk->grid($gene),
    (defined $strike ? $strike == 1 ? 'Hit!' : 'Miss' : 'Duplicate strike'),
), "\n";
