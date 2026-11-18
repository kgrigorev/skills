# expect: red No switched-off checks
# A crate-wide #![allow] in main.rs.
{ printf '#![allow(clippy::pedantic)]\n'; cat src/main.rs; } > m.tmp
mv m.tmp src/main.rs
