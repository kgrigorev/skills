# expect: red Haskell sources are plain .hs files
# A source folder with a space: the file lists split at spaces, so no step would read the file.
mkdir -p 'bench x'
printf -- '-- | Bench.\nmodule Main (main) where\n\n-- | Runs.\nmain :: IO ()\nmain = pure ()\n' >'bench x/Main.hs'
printf '\nexecutable bench\n  import: common\n  hs-source-dirs: "bench x"\n  main-is: Main.hs\n' >>sample-tool.cabal
scripts/format >/dev/null 2>&1 || true
