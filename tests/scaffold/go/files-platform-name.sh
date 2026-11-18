# expect: red Every file is checked
# A _plan9.go file is left out of the build on this machine.
printf 'package sampletool\n\nvar _ = undefinedThing\n' >broken_plan9.go
