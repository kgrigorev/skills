# expect: green
# Changes outside the C code: a README section, a personal CMakeUserPresets.json, and an
# editor folder. None of them change a gate.
printf '\n## Usage\n\nRun `build/dev/sample-tool`.\n' >>README.md
printf '{"version": 6, "configurePresets": [{"name": "mine", "inherits": "dev"}]}\n' >CMakeUserPresets.json
mkdir -p .idea
printf '<project/>\n' >.idea/workspace.xml
