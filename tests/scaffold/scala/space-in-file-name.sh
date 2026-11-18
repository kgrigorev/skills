# expect: red Sources only in src/
# A file name with a space: the scans split the file list on spaces, Scala CLI still compiles it.
cat > 'src/main/scala/Bad File.scala' <<'EOF'
//> using options -Wconf:any:s
package sampletool

import scala.annotation.nowarn

object Bad:
  @nowarn
  private def unused(): Int = 1
  def z: Int = List(1).head
EOF
