# expect: red No switched-off checks
# "rust ignore" with a space, which rustdoc accepts.
perl -0pi -e 's{^/// ```$}{/// ```rust ignore}m' src/lib.rs
perl -pi -e 's/three"\), 3\)/three"), 99)/' src/lib.rs
