# expect: red Settings files
# An escaped "retries" key.
printf '\n[[profile.default.overrides]]\nfilter = "all()"\n"retri\\u0065s" = 5\n' >> .config/nextest.toml
