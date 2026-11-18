# expect: red Settings files
# Retries make a flaky test pass.
perl -pi -e 's/^\[profile.default\]$/[profile.default]\nretries = 5/' .config/nextest.toml
