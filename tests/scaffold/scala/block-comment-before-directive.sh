# expect: red Build settings only in project.scala
# Variant of bom-before-directive: a block comment, not a BOM, before //> on the same line.
printf '/* build */ //> using options -Wconf:any:s\npackage sampletool\n\n/** b */\nobject Bad:\n  private def unused(): Int = 1\n' > src/main/scala/Bad.scala
