BEGIN {
    use strict;
    use Test::More 'no_plan';#tests => 18;
    use_ok 'Games::Battleship';
}

my $obj = eval { Games::Battleship->new };
print "$@\n" if $@;
isa_ok $obj, 'Games::Battleship', 'with no arguments';

$obj = Games::Battleship->new('gene', 'aeryk');
isa_ok $obj, 'Games::Battleship', 'with named players';

my $gene  = $obj->player('gene');
isa_ok $gene, 'Games::Battleship::Player',
    'gene by object';
my $aeryk = $obj->player('aeryk');
isa_ok $aeryk, 'Games::Battleship::Player',
    'aeryk by object';

my $stephi = $obj->add_player('stephi');
isa_ok $stephi, 'Games::Battleship::Player', 'stephi';
is $stephi->{id}, 3, 'generated player id number';
isa_ok $obj->player(3), 'Games::Battleship::Player',
    'stephi by number';
isa_ok $obj->player('player_3'), 'Games::Battleship::Player',
    'stephi by key';
isa_ok $obj->player('stephi'), 'Games::Battleship::Player',
    'stephi by name';

my $bogus = $obj->player('bogus');
is $bogus, undef, 'bogus is not a player';

is join( ',', sort map { $_->name } @{ $obj->players } ),
    'aeryk,gene,stephi', 'players';

my $craft = $aeryk->craft(id => 'A');
isa_ok $craft, 'Games::Battleship::Craft', 'by id';
isa_ok $aeryk->craft(name => 'aircraft carrier'),
    'Games::Battleship::Craft', 'by name';
ok $craft->hit == $craft->{points} - 1, 'craft hit';

my $ggrid = $gene->grid;
ok length($ggrid), "gene's initial grid:\n" . join( "\n", $ggrid );
my $agrid = $aeryk->grid;
ok length($agrid), "aeryk's initial grid:\n" . join( "\n", $agrid );

my $strike;
my $count = 0;

for my $i ( 0 .. 9 ) {
    for my $j ( 0 .. 9 ) {
        if( $count++ % 2 ) {
            $strike = $aeryk->strike($gene, $i, $j);
            ok $strike == 0 || $strike == 1,
                "aeryk strikes gene at row=$i, col=$j";
            $agrid = $aeryk->grid($gene);
#            ok length($agrid), "aeryk vs gene grid:\n" . join( "\n", $agrid );
        }
        else {
            $strike = $gene->strike($aeryk, $i, $j);
            ok length($strike),
                "gene strikes aeryk at row=$i, col=$j";
            $ggrid = $gene->grid($aeryk);
#            ok length($ggrid), "gene vs aeryk grid:\n" . join( "\n", $ggrid );
        }

        ok $strike == 0 || $strike == 1 || $strike == -1,
            "..and it's a ($strike) " .
            ($strike == 1 ? 'hit!' :
             $strike == 0 ? 'miss.'
                          : 'duplicate strike?');
    }
}

    $strike = $gene->strike($aeryk, 0, 0);
    ok length($strike),
        "gene strikes aeryk at row=0, col=0";
    $ggrid = $gene->grid($aeryk);
#    ok length($ggrid), "gene vs aeryk grid:\n" . join( "\n", $ggrid );
    ok $strike == 0 || $strike == 1 || $strike == -1,
        "..and it's a ($strike) " .
        ($strike == 1 ? 'hit!' :
         $strike == 0 ? 'miss.'
                      : 'duplicate strike?');

$ggrid = $gene->grid;
ok length($ggrid), "gene's resulting grid:\n" . join( "\n", $ggrid );
$agrid = $aeryk->grid;
ok length($agrid), "aeryk's resulting grid:\n" . join( "\n", $agrid );

__END__
# This works great but is sometimes seemingly infinitely long...
#$obj = Games::Battleship->new('gene', 'aeryk');
$obj->play;
