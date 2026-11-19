# expect: red Settings files
# A TOML 1.1 inline table over two lines hides on-timeout = "pass" on its second line.
perl -pi -e 's/terminate-after = 2 \}/terminate-after = 2,\n  on-timeout = "pass" }/' .config/nextest.toml
grep -q '^  on-timeout' .config/nextest.toml
