# expect: red Build settings only in project.scala
# A dependency with a version range.
printf '//> using dep org.typelevel::cats-core:2.+\n' >> project.scala
