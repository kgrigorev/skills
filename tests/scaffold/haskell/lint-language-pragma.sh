# expect: red Lint
# A LANGUAGE pragma: extensions are set once, in the .cabal file.
perl -0pi -e 's/\A/{-# LANGUAGE LambdaCase #-}\n\n/' src/SampleTool.hs
