#!/usr/bin/env bash
# Fixture-based tests for scripts/check_translations.py
set -u
cd "$(dirname "$0")/.."
PASS=0; FAIL=0

make_fixture() { # $1=dir
  mkdir -p "$1/en/posts" "$1/pt/posts"
}
write_post() { # $1=path $2=key $3=draft
  printf -- '---\ntitle: "T"\ndate: 2026-08-18\ndraft: %s\ntranslationKey: "%s"\n---\nbody\n' "$3" "$2" > "$1"
}
check() { # $1=name $2=expected_exit $3=fixture_dir
  python3 scripts/check_translations.py "$3" > /tmp/ct_out 2>&1
  local got=$?
  if [ "$got" -eq "$2" ]; then PASS=$((PASS+1)); echo "ok: $1"
  else FAIL=$((FAIL+1)); echo "FAIL: $1 (expected exit $2, got $got)"; cat /tmp/ct_out; fi
}

FX=$(mktemp -d)

# 1. Complete mirror passes
make_fixture "$FX/complete"
write_post "$FX/complete/en/posts/a.md" "a" false
write_post "$FX/complete/pt/posts/a.md" "a" false
check "complete mirror passes" 0 "$FX/complete"

# 2. Missing PT pair fails
make_fixture "$FX/missing-pt"
write_post "$FX/missing-pt/en/posts/a.md" "a" false
check "missing PT pair fails" 1 "$FX/missing-pt"

# 3. Missing EN pair fails
make_fixture "$FX/missing-en"
write_post "$FX/missing-en/pt/posts/a.md" "a" false
check "missing EN pair fails" 1 "$FX/missing-en"

# 4. Draft without pair passes (drafts exempt)
make_fixture "$FX/draft"
write_post "$FX/draft/en/posts/a.md" "a" true
check "draft without pair passes" 0 "$FX/draft"

# 5. Non-draft post missing translationKey fails
make_fixture "$FX/nokey"
printf -- '---\ntitle: "T"\ndate: 2026-08-18\ndraft: false\n---\nbody\n' > "$FX/nokey/en/posts/a.md"
check "missing translationKey fails" 1 "$FX/nokey"

# 6. Duplicate translationKey in one language fails
make_fixture "$FX/dupe"
write_post "$FX/dupe/en/posts/a.md" "a" false
write_post "$FX/dupe/en/posts/b.md" "a" false
write_post "$FX/dupe/pt/posts/a.md" "a" false
check "duplicate key in one language fails" 1 "$FX/dupe"

rm -rf "$FX"
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
