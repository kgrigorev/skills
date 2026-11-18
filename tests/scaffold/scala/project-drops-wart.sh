# expect: red Build settings only in project.scala
# One WartRemover wart removed from project.scala.
perl -ni -e 'print unless /warts\.Var$/' project.scala
! grep -q 'warts.Var$' project.scala
