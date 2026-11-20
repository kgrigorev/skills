# expect: red Every file is checked
# A library package directly in cmd/, where printing is allowed and no tests are needed.
mkdir -p cmd/greet
cat >cmd/greet/greet.go <<'GO'
// Package greet prints greetings.
package greet

import "fmt"

// Say prints the greeting for name.
func Say(name string) { fmt.Println("Hello, " + name + "!") }
GO
