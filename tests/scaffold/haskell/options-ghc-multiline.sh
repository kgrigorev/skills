# expect: red Format
# An OPTIONS_GHC pragma split over lines. Ormolu joins it, so Format fails first.
perl -0pi -e 's/\A/{-#\n  OPTIONS_GHC -Wno-unused-top-binds\n#-}\n\n/' src/SampleTool.hs
