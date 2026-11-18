# expect: red Build settings
# The common stanza switches GADTs off; the library switches them back on in the .cabal file.
perl -0pi -e 's/(  exposed-modules: SampleTool\n)/$1  default-extensions: GADTs\n/' sample-tool.cabal
perl -0pi -e 's/\(banner, tidyName\)/(Expr (..), banner, eval, tidyName)/' src/SampleTool.hs
cat >>src/SampleTool.hs <<'HS'

-- | A typed expression.
data Expr a where
  IntE :: Int -> Expr Int
  BoolE :: Bool -> Expr Bool

-- | Evaluates an expression.
eval :: Expr a -> a
eval expr = case expr of
  IntE n -> n
  BoolE b -> b
HS
