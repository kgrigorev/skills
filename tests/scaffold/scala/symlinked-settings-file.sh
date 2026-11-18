# expect: red Sources only in src/
# A symlinked file that silences warnings and disables WartRemover for a sloppy file.
mkdir -p notes
printf '//> using options -Wconf:any:s -Xplugin-disable:wartremover\npackage sampletool\n' > notes/settings.txt
ln -s ../../../notes/settings.txt src/main/scala/Settings.scala
cat > src/main/scala/Sloppy.scala <<'EOF'
package sampletool

import java.util.UUID

/** s */
object Sloppy:
  private def unused(): Int = 1

  /** y */
  def y: Int =
    List(1).map(_ + 1)
    var x = List(1).head
    x = 2
    x
EOF
