# expect: red Lint
# A godebug line in go.mod switches a runtime default (gomoddirectives).
printf '\ngodebug panicnil=1\n' >>go.mod
