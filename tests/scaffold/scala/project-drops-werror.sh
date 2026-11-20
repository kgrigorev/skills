# expect: red Build settings only in project.scala
# -Werror removed from project.scala.
perl -pi -e 's/^(\/\/> using options )-Werror /$1/' project.scala
! grep -q -- '-Werror' project.scala
