use v6;
use Test;
use Alma::Test;

my @taboo-words = <
    ident
    paramlist
    params
    stmtlist
    arglist
    proplist
    qx[find
    qx!find
>;

my $files = find(".", /[".rakumod" | ".t"] $/)\
        .grep({ $_ !~~ / "taboo-words.t" / })\
        .join(" ");

for @taboo-words -> $WORD {
    my @lines-with-taboo-words =
        qqx[grep -Fwrin $WORD $files].lines\
            # exception: `signature.params` happens in two places;
            # that's the Raku Signature class
            .grep({ $_ !~~ / "signature.params" / });

    is @lines-with-taboo-words.join("\n"), "",
        "the word '$WORD' is not mentioned in the code base";
}

done-testing;
