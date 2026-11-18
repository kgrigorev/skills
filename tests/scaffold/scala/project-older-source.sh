# expect: red Build settings only in project.scala
# -source:future replaced by an older source level.
perl -pi -e 's/-source:future/-source:3.4/' project.scala
grep -q 'source:3.4' project.scala
