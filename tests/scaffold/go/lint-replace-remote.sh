# expect: red Lint
# A replace directive that swaps a dependency for a fork. go.sum holds the fork's lines, so
# go mod tidy is satisfied and gomoddirectives must reject it.
printf '\nreplace pgregory.net/rapid => github.com/flyingmutant/rapid v1.2.0\n' >>go.mod
cat >go.sum <<'SUM'
github.com/flyingmutant/rapid v1.2.0 h1:Q1tcwK/FW7y0pgd3YYdEhlMm2GCwsz0cPDQkI7aTUnU=
github.com/flyingmutant/rapid v1.2.0/go.mod h1:PY5XlDGj0+V1FCq0o192FdRhpKHGTRIWBgqjDBTrq04=
SUM
