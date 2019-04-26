use _007::Val;
use _007::Value;
use _007::Q;

# These multis are used below by infix:<==> and infix:<!=>
multi equal-value($, $) is export { False }
multi equal-value(Val::None, Val::None) { True }
multi equal-value(Val::Array $l, Val::Array $r) {
    if %*equality-seen{$l.WHICH} && %*equality-seen{$r.WHICH} {
        return $l === $r;
    }
    %*equality-seen{$l.WHICH}++;
    %*equality-seen{$r.WHICH}++;

    sub equal-at-index($i) {
        equal-value($l.elements[$i], $r.elements[$i]);
    }

    [&&] $l.elements == $r.elements,
        |(^$l.elements).map(&equal-at-index);
}
multi equal-value(Val::Dict $l, Val::Dict $r) {
    if %*equality-seen{$l.WHICH} && %*equality-seen{$r.WHICH} {
        return $l === $r;
    }
    %*equality-seen{$l.WHICH}++;
    %*equality-seen{$r.WHICH}++;

    sub equal-at-key(Str $key) {
        equal-value($l.properties{$key}, $r.properties{$key});
    }

    [&&] $l.properties.keys.sort.perl eq $r.properties.keys.sort.perl,
        |($l.properties.keys).map(&equal-at-key);
}
multi equal-value(Val::Type $l, Val::Type $r) {
    $l.type === $r.type
}
multi equal-value(Val::Func $l, Val::Func $r) {
    $l === $r
}
multi equal-value(Q $l, Q $r) {
    sub same-avalue($attr) {
        equal-value($attr.get_value($l), $attr.get_value($r));
    }

    [&&] $l.WHAT === $r.WHAT,
        |$l.attributes.map(&same-avalue);
}

multi equal-value(_007::Value $l, _007::Value $r) {
    return is-int($l) && is-int($r) && $l.native-value == $r.native-value
        || is-str($l) && is-str($r) && $l.native-value eq $r.native-value
        || is-bool($l) && is-bool($r) && $l === $r
        || is-type($l) && is-type($r) && $l === $r;
}
