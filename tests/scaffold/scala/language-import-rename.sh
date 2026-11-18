# expect: red No switched-off checks
# scala.language imported under another name.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.{
  language as l
}
import l.implicitConversions

/** x */
object X:
  given Conversion[String, Int] = _.length

  /** y */
  def n: Int = "abc"
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
