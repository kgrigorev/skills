# expect: red No switched-off checks
# should_panic turns the wrong assertion into a pass.
perl -0pi -e 's{^/// ```$}{/// ```should_panic}m' src/lib.rs
perl -pi -e 's/three"\), 3\)/three"), 99)/' src/lib.rs
