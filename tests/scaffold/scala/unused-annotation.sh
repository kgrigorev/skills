# expect: red No switched-off checks
# @unused on an unused parameter.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.annotation.unused

/** x */
object X:
  private def f(@unused n: Int): Int = 1

  /** y */
  def y: Int = f(2)
EOF
scripts/format >/dev/null
