# expect: red Format (scalafmt
# import x._: scalafmt rewrites it to x.*, so the format step catches it first.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.util._

/** x */
object X:
  /** y */
  def y: Try[Int] = Success(1)
EOF
