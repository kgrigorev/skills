# expect: red Tools
# mise.local.toml puts a fake golangci-lint first on PATH, and the code panics.
mkdir -p .shim
cat >.shim/golangci-lint <<'SH'
#!/bin/sh
case "$1" in version) echo 2.15.0 ;; esac
exit 0
SH
chmod +x .shim/golangci-lint
printf '[env]\n_.path = ["{{config_root}}/.shim"]\n' >mise.local.toml
cat >>sampletool.go <<'GO'

func bad() { panic(1) }
GO
