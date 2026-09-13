#!/usr/bin/env bash
# Structural checks for the skill directory. Run from the repository root.
set -euo pipefail

fail() { echo "FAIL: $1" >&2; exit 1; }

[ -f SKILL.md ] || fail "SKILL.md missing"
[ -f README.md ] || fail "README.md missing"
[ -f README_CN.md ] || fail "README_CN.md missing"
[ -f LICENSE ] || fail "LICENSE missing"

head -1 SKILL.md | grep -qx -- '---' || fail "SKILL.md must start with YAML front matter"
grep -q '^name: ' SKILL.md || fail "front matter: name missing"
grep -q '^description: ' SKILL.md || fail "front matter: description missing"

for f in workflow kunshan-suites build-matrix reports pitfalls; do
    [ -f "references/$f.md" ] || fail "references/$f.md missing"
done

# Ensure referenced files exist
grep -oE 'references/[a-z-]+\.md' SKILL.md | sort -u | while read -r ref; do
    [ -f "$ref" ] || fail "SKILL.md references a missing file: $ref"
done

# Sanitization guard: personal identifiers must not appear.
# Exclude this script itself (it contains the search patterns).
if grep -rInE 'luql|/public/home/[a-z]+|1219[0-9]{5}' . \
    --exclude-dir=.git --exclude=validate.sh; then
    fail "possible personal identifier found"
fi

echo "OK: skill structure and sanitization checks passed"
