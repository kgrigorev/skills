# expect: red Build settings only in project.scala
# -Xplugin-disable:wartremover added to project.scala.
printf '//> using options -Xplugin-disable:wartremover\n' >> project.scala
