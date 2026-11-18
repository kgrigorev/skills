# expect: red No switched-off checks in the compiled code
# Properties imported under another name. The update call is ascribed to Unit, so no discarded
# value fails the build; munit never runs the object.
cat > src/test/scala/P.scala <<'X'
package sampletool

import org.scalacheck.{Prop, Properties as Props}

object BrokenProps extends Props("p"):
  property.update("broken", Prop.forAll((n: Int) => n != n)): Unit
X
mise exec -- scala-cli fmt project.scala src >/dev/null
grep -q 'Props("p")' src/test/scala/P.scala
