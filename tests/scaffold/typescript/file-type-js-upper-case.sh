# expect: red Only .ts sources, and only the gate configs
# A .JS file, which a case-sensitive extension check misses.
printf 'export const x = 1;\n' >src/x.JS
