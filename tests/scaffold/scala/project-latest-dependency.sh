# expect: red Build settings only in project.scala
# A dependency on latest.release resolves to other code over time.
printf '//> using dep org.typelevel::cats-core:latest.release\n' >> project.scala
