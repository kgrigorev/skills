# expect: red No switched-off checks
# A doc example marked ignore, with a wrong assertion.
perl -0pi -e 's{^/// ```$}{/// ```ignore}m' src/lib.rs
perl -pi -e 's/three"\), 3\)/three"), 99)/' src/lib.rs
