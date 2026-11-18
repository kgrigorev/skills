# expect: red Test
# A wrong doc example.
perl -pi -e 's/three"\), 3\)/three"), 99)/' src/lib.rs
