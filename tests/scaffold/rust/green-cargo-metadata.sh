# expect: green
# More package metadata, a multi-line array, a feature and a comment with "allow" in Cargo.toml.
perl -pi -e 's/^publish = false$/publish = false\nkeywords = [\n  "ledger",\n  "words",\n]\ncategories = ["command-line-utilities"]\nreadme = "README.md"/' Cargo.toml
printf '\n# Features: none yet. Lints never "allow" here.\n[features]\ndefault = []\n' >> Cargo.toml
