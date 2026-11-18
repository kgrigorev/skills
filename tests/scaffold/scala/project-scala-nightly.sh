# expect: red Build settings only in project.scala
# A Scala version that is not exact.
perl -pi -e 's|^//> using scala 3.9.0$|//> using scala 3.nightly|' project.scala
grep -q nightly project.scala
