# expect: red Tools
# mise.toml pins another golangci-lint than the one mise.lock installs.
sed 's/^golangci-lint = ".*"$/golangci-lint = "2.14.0"/' mise.toml >x.tmp && mv x.tmp mise.toml
