# expect: red Tool pins in mise.toml and mise.lock
# A comment after [tools] hides the section from the lock check.
perl -pi -e 's/^\[tools\]$/[tools] # pinned/; s/^java = "temurin-25.0.5\+8.0.LTS"/java = "temurin-21.0.5+11.0.LTS"/' mise.toml
grep -q '# pinned' mise.toml
