# expect: red No switched-off checks
# nowarn imported under another name, over several lines.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.annotation.{
  nowarn as q
}

/** x */
object X:
  @q
  private def unused(): Int = 1

  /** y */
  def y: Int = 2
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
