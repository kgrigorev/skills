# expect: red Build settings only in project.scala
# A //> using line in a test file adds a dependency.
perl -0pi -e 's/^package sampletool/\/\/> using test.dep com.lihaoyi::os-lib:0.11.4\npackage sampletool/' src/test/scala/SampleToolSuite.scala
mise exec -- scala-cli fmt project.scala src >/dev/null
