def main [ delta: int ]: nothing -> nothing {
    get-current | apply-delta $delta | set-new
}

def get-current []: nothing -> record<t: int, r: int, b: int, l: int> {
    let output = ^hyprctl getoption -j general:gaps_out
    (
        $output | from json | get custom # string
        | parse "{t} {r} {b} {l}" | get 0 # record<string>
        | transpose k v | update v { into int } | transpose -ird # record<int>
    )
}

def apply-delta [
    delta: int
]: record<t: int, r: int, b: int, l: int> -> record<t: int, r: int, b: int, l: int> {
    let f = { [($in + $delta) 0] | math max }
    $in | update r $f | update l $f
}

def set-new []: record<t: int, r: int, b: int, l: int> -> nothing {
    ^hyprctl keyword general:gaps_out $"($in.t),($in.r),($in.b),($in.l)"
}
