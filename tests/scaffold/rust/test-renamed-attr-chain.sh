# expect: red Test
# The test attribute renamed twice, on a hidden red test.
cat >> tests/sample_tool.rs <<'R'

use core::prelude::v1::test as t1;
use t1 as check;

#[check]
fn visible() {
    assert_eq!(word_count("a"), 1);
}

#[cfg(miri)]
#[check]
fn hidden_red() {
    assert_eq!(word_count("a"), 99);
}
R
