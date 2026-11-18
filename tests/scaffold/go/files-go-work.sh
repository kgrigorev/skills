# expect: red Every file is checked
# A go.work file, which changes the build for anyone who runs go without GOWORK=off.
printf 'go 1.27.0\n\nuse .\n' >go.work
