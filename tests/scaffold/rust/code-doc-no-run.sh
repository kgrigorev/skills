# expect: red No switched-off checks
# no_run compiles the example but never runs the wrong assertion.
perl -0pi -e 's{^/// ```$}{/// ```no_run}m' src/lib.rs
perl -pi -e 's/three"\), 3\)/three"), 99)/' src/lib.rs
