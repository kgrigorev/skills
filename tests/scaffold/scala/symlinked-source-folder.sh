# expect: red Sources only in src/
# A symlinked folder under src/.
mkdir -p notes/lib
printf '//> using options -Wconf:any:s\npackage sampletool\n' > notes/lib/S.txt
ln -s ../../../notes/lib src/main/scala/lib
