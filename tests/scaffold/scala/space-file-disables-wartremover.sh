# expect: red Sources only in src/
# A spaced file name that silences warnings and disables WartRemover.
printf '//> using options -Wconf:any:s -Xplugin-disable:wartremover\npackage sampletool\n' > 'src/main/scala/build settings.scala'
cat > src/main/scala/Sloppy.scala <<'EOF'
package sampletool

/** s */
object Sloppy:
  private def unused(): Int = 1

  /** y */
  def y: Int =
    var x = List(1).head
    x = 2
    x
EOF
