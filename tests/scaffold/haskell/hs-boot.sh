# expect: red Haskell sources are plain .hs files
# A boot file: GHC reads it, the format, lint and switch-off steps do not.
echo 'module SampleTool where' >src/SampleTool.hs-boot
