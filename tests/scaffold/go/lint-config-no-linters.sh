# expect: red Lint
# Every linter and formatter is removed from the config.
sed 's/^  default: standard/  default: none/' .golangci.yml | awk '
  /^  enable:$/ { skip = 1; next }
  skip && /^    [-#]/ { next }
  { skip = 0; print }' >x.tmp && mv x.tmp .golangci.yml
cat >>sampletool.go <<'GO'

func bad() { panic(1) }
GO
