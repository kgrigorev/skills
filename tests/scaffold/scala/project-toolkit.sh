# expect: red Build settings only in project.scala
# The Scala toolkit pulls in many unpinned libraries.
printf '//> using toolkit default\n' >> project.scala
