# expect: red Build settings only in project.scala
# A byte-order mark before //>. Scala CLI still reads the directive there, so the scan looks for
# //> anywhere in a line.
printf '\357\273\277//> using options -Wconf:any:s\npackage sampletool\n\nobject Bad:\n  private def unused(): Int = 1\n' > src/main/scala/Bad.scala
