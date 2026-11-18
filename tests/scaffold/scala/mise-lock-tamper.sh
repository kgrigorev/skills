# expect: red Tool pins in mise.toml and mise.lock
# mise.lock edited by hand to another Scala CLI version.
perl -0pi -e 's/version = "1.19.0"/version = "1.18.0"/' mise.lock
grep -q '1.18.0' mise.lock
