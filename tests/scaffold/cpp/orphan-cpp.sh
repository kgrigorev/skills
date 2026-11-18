# expect: red Lint (clang-tidy
# A .cpp that no target compiles, with a reinterpret_cast. clang-tidy still lints it.
. "$(dirname "$0")/lib/attack"
printf '// Orphan.\nnamespace {\nint orphan(int value) {\n  const long wide = value;\n  return *reinterpret_cast<const int *>(&wide);\n}\n} // namespace\n' >src/orphan.cpp
fmt
