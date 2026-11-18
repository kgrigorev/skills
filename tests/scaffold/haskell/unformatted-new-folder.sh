# expect: red Format
# A Haskell file in a new folder, not listed in the .cabal file: the gates still read it.
mkdir tools
cat >tools/Gen.hs <<'HS'
module Main (main) where
main :: IO ()
main = do { print 1 ; print 2 }
HS
