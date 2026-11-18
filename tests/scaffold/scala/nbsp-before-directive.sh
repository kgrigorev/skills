# expect: red Build settings only in project.scala
# Variant of bom-before-directive: a no-break space (U+00A0) before //>, which [[:space:]] misses.
printf '\302\240//> using options -Wconf:any:s\npackage sampletool\n\n/** b */\nobject Bad:\n  private def unused(): Int = 1\n' > src/main/scala/Bad.scala
