# expect: red Tool versions
# mise.local.toml turns leak detection off for the tests.
printf '[env]\nLSAN_OPTIONS = "detect_leaks=0"\n' >mise.local.toml
