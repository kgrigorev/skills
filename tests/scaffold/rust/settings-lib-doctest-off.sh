# expect: red Settings files
# [lib] doctest = false, with a wrong doc example.
printf '\n[lib]\ndoctest = false\n' >> Cargo.toml
perl -pi -e 's/three"\), 3\)/three"), 99)/' src/lib.rs
