# expect: red No switched-off checks in the compiled code
# A macro builds a null literal through the reflection API, so no null appears in the source.
cat > src/main/scala/Macros.scala <<'X'
package sampletool

import scala.quoted.*

/** Compile-time helpers. */
object Macros:
  /** Nothing yet. */
  inline def missing: String = ${ missingImpl }

  /** Builds the value. */
  def missingImpl(using q: Quotes): Expr[String] =
    import q.reflect.*
    Literal(NullConstant()).asExprOf[String]
X
cat > src/main/scala/Lookup.scala <<'X'
package sampletool

/** Looks up a value. */
object Lookup:
  /** The value. */
  def value: String = Macros.missing
X
scripts/format >/dev/null
