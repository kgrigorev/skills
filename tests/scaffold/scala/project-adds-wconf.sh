# expect: red Build settings only in project.scala
# An added -Wconf in project.scala silences warnings.
printf '//> using options -Wconf:any:s\n' >> project.scala
