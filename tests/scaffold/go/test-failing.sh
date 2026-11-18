# expect: red Test (race
# A test that fails.
sed 's/HasPrefix(got/HasPrefix("x"+got/' sampletool_test.go >x.tmp && mv x.tmp sampletool_test.go
