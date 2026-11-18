# expect: red Test
# The test attribute under another name, on a hidden red test.
cat >> tests/sample_tool.rs <<'R'

use core::prelude::v1::test as check;

#[cfg(miri)]
#[check]
fn hidden_red() {
    assert_eq!(1, 2);
}

#[check]
fn visible() {
    assert_eq!(1, 1);
}
R
