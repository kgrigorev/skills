# expect: red Warning settings
# A new executable whose import: common is not its first field.
printf '\nexecutable extra\n  hs-source-dirs: tools\n  import: common\n  main-is: Main.hs\n' >>sample-tool.cabal
mkdir tools
printf -- '-- | Extra.\nmodule Main (main) where\n\n-- | Main.\nmain :: IO ()\nmain = pure ()\n' >tools/Main.hs
