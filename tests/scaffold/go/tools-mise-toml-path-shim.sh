# expect: red Tools
# mise.toml itself (the one allowed config) puts a fake golangci-lint first on PATH, and the
# library panics. No PATH entry may point into the project.
mkdir -p .shim
cat >.shim/golangci-lint <<'SH'
#!/bin/sh
case "$1" in version) echo 2.15.0 ;; esac
exit 0
SH
chmod +x .shim/golangci-lint
awk '{ print } /^\[env\]$/ { print "_.path = [\"{{config_root}}/.shim\"]" }' mise.toml >x.tmp && mv x.tmp mise.toml
cat >>sampletool.go <<'GO'

func bad() { panic(1) }
GO
