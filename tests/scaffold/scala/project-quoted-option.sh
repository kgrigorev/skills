# expect: red Build settings only in project.scala
# A quoted option escapes the option comparison.
perl -pi -e 's|^//> using options -Werror -Wall|//> using options "-Werror" -Wall|' project.scala
grep -q 'options "-Werror"' project.scala
