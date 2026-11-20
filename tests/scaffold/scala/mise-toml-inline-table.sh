# expect: red Tool pins in mise.toml and mise.lock
# A JDK pin in TOML inline-table form, which the lock check does not read.
perl -pi -e 's/^java = "temurin-25.0.5\+8.0.LTS"/java = { version = "temurin-21.0.5+11.0.LTS" }/' mise.toml
grep -q 'java = {' mise.toml
