# expect: red No switched-off checks
# @annotation.nowarn written in full.
perl -pi -e 's/^  def greet/  \@annotation.nowarn\n  def greet/' src/main/scala/SampleTool.scala
mise exec -- scala-cli fmt project.scala src >/dev/null
