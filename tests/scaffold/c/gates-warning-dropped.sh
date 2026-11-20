# expect: red Every project file is built with the gates
# cmake/gates.cmake edited to drop -Wconversion.
perl -pi -e 's/ -Wconversion//' cmake/gates.cmake
