# expect: red Build and test
# A mutable collection.
cat > src/main/scala/X.scala <<'EOF'
package sampletool

import scala.collection.mutable

/** x */
object X:
  /** y */
  def y: Int =
    val b = mutable.ListBuffer(1)
    b.size
EOF
scripts/format >/dev/null
