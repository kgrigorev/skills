# expect: red Lint
# The library logs through slog's package functions.
cat >>sampletool.go <<'GO'

// Note logs a greeting.
func Note(name string) { slog.Info("greeted", "name", name) }
GO
awk '{ print } $0 == "package sampletool" { print ""; print "import \"log/slog\"" }' sampletool.go >x.tmp && mv x.tmp sampletool.go
