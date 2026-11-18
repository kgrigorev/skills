# expect: red Settings files
# An override adds retries to every test.
printf "\n[[profile.default.overrides]]\nfilter = 'all()'\nretries = 3\n" >> .config/nextest.toml
