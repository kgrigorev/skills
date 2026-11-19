# expect: red No switched-off checks
# A JSDoc line may leave out its leading "*". The @public tag on it still makes knip keep the
# unused export.
cat >>src/sample-tool.ts <<'X'

/**
   Kept for later.
   @public
 */
export const unused = 1;
X
