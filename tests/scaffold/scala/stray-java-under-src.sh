# expect: red Sources only in src/
# A .java file under src/, which skips scalafmt, WartRemover and -Werror.
mkdir -p src/main/java
printf 'package sampletool;\npublic class J { public static String s = null; }\n' > src/main/java/J.java
