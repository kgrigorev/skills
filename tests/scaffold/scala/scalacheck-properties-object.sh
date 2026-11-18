# expect: red No switched-off checks
# A plain ScalaCheck Properties object, which munit never runs. The property is ascribed to Unit,
# so no discarded value fails the build.
cat > src/test/scala/Props.scala <<'EOF'
package sampletool

import org.scalacheck.Prop.forAll
import org.scalacheck.Properties

object Props extends Properties("p"):
  property.update("never", forAll((i: Int) => i != i)): Unit
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
