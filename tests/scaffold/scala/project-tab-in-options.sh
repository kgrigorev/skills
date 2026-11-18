# expect: red Build settings only in project.scala
# A tab between options escapes the option comparison.
perl -pi -e 's|^//> using options -Werror -Wall -deprecation|//> using options -Werror -Wall\t-deprecation|' project.scala
grep -q "$(printf '\t')-deprecation" project.scala
