# expect: red No switched-off checks
# @`nowarn` in backticks.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.annotation.`nowarn`

/** x */
object X:
  @`nowarn`
  private def unused(): Int = 1

  /** y */
  def y: Int = 2
EOF
scripts/format >/dev/null
