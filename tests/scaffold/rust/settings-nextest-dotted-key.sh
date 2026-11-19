# expect: red Settings files
# The same setting as a dotted key after an allowed key.
perl -pi -e 's/^\[profile.default\]$/[profile.default]\nslow-timeout.on-timeout = "pass"/' .config/nextest.toml
perl -ni -e 'print unless /^slow-timeout = /' .config/nextest.toml
perl -pi -e 's/^(slow-timeout.on-timeout.*)$/$1\nslow-timeout.period = "30s"/' .config/nextest.toml
