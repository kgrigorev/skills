# expect: red No switched-off checks
# import scala.language.implicitConversions.
perl -0pi -e 's/package sampletool\n\n/package sampletool\n\nimport scala.language.implicitConversions\n\n/' src/main/scala/SampleTool.scala
mise exec -- scala-cli fmt project.scala src >/dev/null
