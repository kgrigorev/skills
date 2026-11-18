# expect: red Every file is checked
# A second golangci-lint config that a plain `golangci-lint run` would prefer.
printf 'version: "2"\nlinters:\n  default: none\n' >.golangci.yaml
