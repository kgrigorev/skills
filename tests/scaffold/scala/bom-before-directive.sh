# expect: red Build and test
# A byte-order mark before //> hides it from the directive scan; Scala CLI rejects the file.
printf '\357\273\277//> using options -Wconf:any:s\npackage sampletool\n\nobject Bad:\n  private def unused(): Int = 1\n' > src/main/scala/Bad.scala
