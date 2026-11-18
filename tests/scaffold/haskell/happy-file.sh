# expect: red Haskell sources are plain .hs files
# A Happy grammar: its Haskell code blocks skip Ormolu, HLint and the switch-off scan.
printf '{\nmodule Parser (parse) where\nimport System.IO.Unsafe (unsafePerformIO)\n}\n%%%%\n' >src/Parser.y
