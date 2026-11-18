# expect: red Test (race
# A new package with a _test.go file that holds no test.
mkdir -p internal/util
printf '// Package util doubles.\npackage util\n\n// Double returns twice n.\nfunc Double(n int) int { return n * 3 }\n' >internal/util/util.go
printf '// Tests for package util.\npackage util_test\n' >internal/util/util_test.go
