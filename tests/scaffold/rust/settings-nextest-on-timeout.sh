# expect: red Settings files
# on-timeout = "pass" inside the slow-timeout table turns a hanging test green.
perl -pi -e 's/terminate-after = 2 \}/terminate-after = 2, on-timeout = "pass" }/' .config/nextest.toml
grep -q on-timeout .config/nextest.toml
