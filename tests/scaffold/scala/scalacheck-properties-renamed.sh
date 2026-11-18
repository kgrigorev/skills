# expect: red Build and test
# Properties imported under another name; its property statement is a discarded value.
cat > src/test/scala/P.scala <<'EOF'
package sampletool

import org.scalacheck.{Prop, Properties as Props}

object BrokenProps extends Props("p"):
  property("broken") = Prop.forAll((n: Int) => n != n)
EOF
mise exec -- scala-cli fmt project.scala src >/dev/null
