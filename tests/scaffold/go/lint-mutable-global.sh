# expect: red Lint
# Mutable package-level state.
cat >>sampletool.go <<'GO'

// Counter counts greetings.
var Counter = 0
GO
