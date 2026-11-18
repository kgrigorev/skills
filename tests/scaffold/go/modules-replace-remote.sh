# expect: red Modules
# A replace directive that swaps a dependency for a fork.
printf '\nreplace pgregory.net/rapid => github.com/flyingmutant/rapid v1.2.0\n' >>go.mod
