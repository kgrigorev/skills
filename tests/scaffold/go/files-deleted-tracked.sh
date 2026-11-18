# expect: red Every file is checked
# git still lists a file that is gone (skip-worktree keeps the deletion unstaged), and a
# //nolint elsewhere. A missing file once made the whole search fail open.
printf '// Package sampletool holds nothing here.\n\npackage sampletool\n' >extra.go
git add extra.go
git update-index --skip-worktree extra.go
rm extra.go
cat >>sampletool.go <<'GO'

// helper is never used.
func helper() {} //nolint:unused
GO
