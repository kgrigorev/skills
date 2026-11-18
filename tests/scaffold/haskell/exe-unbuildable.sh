# expect: red Build settings
# The executable has a type error; buildable: False hides it from cabal build all.
perl -0pi -e 's/(executable sample-tool\n  import: common\n)/$1  buildable: False\n/' sample-tool.cabal
perl -0pi -e 's/main = Text.putStrLn banner/main = Text.putStrLn (banner <> 1)/' app/Main.hs
grep -q 'banner <> 1' app/Main.hs
