# expect: red Sources only in src/
# A spaced file name that excludes one file from WartRemover.
printf '//> using options -Wconf:any:s -P:wartremover:excluded:%s/src/main/scala/Sloppy.scala\npackage sampletool\n' "$(pwd)" > 'src/main/scala/build settings.scala'
cat > src/main/scala/Sloppy.scala <<'EOF'
package sampletool

import scala.collection.mutable

/** s */
object Sloppy:
  /** y */
  def y: Int =
    var x = List(1).head
    val m = mutable.Map.empty[String, String]
    m.put("a", null)
    x = 2
    x
EOF
