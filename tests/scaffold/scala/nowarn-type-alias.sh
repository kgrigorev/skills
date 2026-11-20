# expect: red No switched-off checks in the compiled code
# nowarn reached through a wildcard import and a type alias: no @, dot, { or , before the word.
cat > src/main/scala/X.scala <<'X'
package sampletool

import scala.annotation.*

/** x */
object X:
  /** Quiet. */
  type Quiet = nowarn

  @Quiet
  private def unused(): Int = 1

  /** y */
  def y: Int = 2
X
scripts/format >/dev/null
grep -q '^  type Quiet = nowarn' src/main/scala/X.scala
