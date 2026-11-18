# expect: red Lint
# env: MISE_ENV=ci
# mise.ci.toml shims golangci-lint for MISE_ENV=ci. scripts/check unsets MISE_ENV, so the real
# linter runs and finds the panic.
mkdir -p .shim
cat >.shim/golangci-lint <<'SH'
#!/bin/sh
case "$1" in version) echo 2.15.0 ;; esac
exit 0
SH
chmod +x .shim/golangci-lint
printf '[env]\n_.path = ["{{config_root}}/.shim"]\n' >mise.ci.toml
cat >>sampletool.go <<'GO'

func bad() { panic(1) }
GO
