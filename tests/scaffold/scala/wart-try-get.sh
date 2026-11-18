# expect: red Build and test
# Try.get.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.util.Try

/** x */
object X:
  /** y */
  def y(s: String): Int = Try(s.length).get
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
