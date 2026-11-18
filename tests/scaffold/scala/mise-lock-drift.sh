# expect: red Tool pins in mise.toml and mise.lock
# mise.toml pins another Scala CLI, and mise.lock was not updated.
perl -pi -e 's/^scala-cli = "1.19.0"/scala-cli = "1.18.0"/' mise.toml
grep -q '1.18.0' mise.toml
