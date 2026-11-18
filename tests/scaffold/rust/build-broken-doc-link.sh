# expect: red Build
# A doc link to an item that does not exist.
perl -pi -e 's{^/// The line the program prints when it starts.$}{/// The line the program prints when it starts. See [`NoSuchItem`].}' src/lib.rs
