use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Games::Battleship',
    VERSION_FROM => 'lib/Games/Battleship.pm',
    PREREQ_PM    => {
        'Test::More' => 0,
    },
    ($] >= 5.005
        ? (ABSTRACT_FROM => 'lib/Games/Battleship.pm',
           AUTHOR        => 'Gene Boggs <gene@cpan.org>')
        : ()
    ),
);
