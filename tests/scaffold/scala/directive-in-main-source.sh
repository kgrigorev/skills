# expect: red Build settings only in project.scala
# A //> using line in a source file silences every warning.
perl -0pi -e 's/^package sampletool/\/\/> using options -Wconf:any:s\npackage sampletool/' src/main/scala/SampleTool.scala
mise exec -- scala-cli fmt project.scala src >/dev/null
