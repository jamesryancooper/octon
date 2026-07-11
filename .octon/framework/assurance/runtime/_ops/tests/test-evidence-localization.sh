#!/usr/bin/env bash
set -euo pipefail
SRC_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
R="$TMP/repo"; H="$TMP/home"; mkdir -p "$R/.octon/instance/governance/policies" "$R/.octon/state/evidence/runs/terminal" "$R/.octon/state/control/execution/runs/terminal" "$H"
cp "$SRC_ROOT/.octon/instance/governance/policies/evidence-localization.yml" "$R/.octon/instance/governance/policies/"
git -C "$R" init -q; git -C "$R" config user.email test@example.com; git -C "$R" config user.name test
git -C "$R" remote add origin https://example.com/acme/repo.git
printf 'base\n' >"$R/README"; printf 'state: closed\n' >"$R/.octon/state/control/execution/runs/terminal/runtime-state.yml"; git -C "$R" add README .octon/instance/governance/policies/evidence-localization.yml .octon/state/control/execution/runs/terminal/runtime-state.yml; git -C "$R" commit -qm base; git -C "$R" branch -M main; git -C "$R" update-ref refs/remotes/origin/main HEAD
printf 'audit evidence\n' >"$R/.octon/state/evidence/runs/terminal/log.txt"
RID="$(python3 -c 'import hashlib; print("sha256:"+hashlib.sha256(b"https://example.com/acme/repo").hexdigest())')"
request() { cat >"$1" <<JSON
{"repository_identity":"$RID","rollback_posture":"restore through retrieve and re-admit as non-authoritative evidence","exclusions":["README"],"entries":[{"source_path":".octon/state/evidence/runs/terminal/log.txt","owning_run_id":"terminal","lifecycle_id":"none","evidence_class":"retained-evidence","retention_reason":"audit","reference_relationships":[],"active_state_verdict":"terminal","active_state_evidence":[".octon/state/control/execution/runs/terminal/runtime-state.yml"],"manual_review_disposition":"not-applicable"}]}
JSON
}
REQ="$TMP/request.json"; request "$REQ"; AUTH=""
CMD=(env HOME="$H" python3 "$SRC_ROOT/.octon/framework/assurance/runtime/_ops/scripts/evidence-localization.py" --root "$R")
OUT="$("${CMD[@]}" localize --request "$REQ")"; AID="$(jq -r .archive_id <<<"$OUT")"; AUTH=".octon/state/evidence/local/evidence-localization/$AID/cleanup.json"; "${CMD[@]}" verify --archive-id "$AID" >/dev/null
# deterministic idempotent replay
"${CMD[@]}" localize --request "$REQ" | jq -e '.reused == true' >/dev/null
"${CMD[@]}" authorize-cleanup --archive-id "$AID" --request "$REQ" --authorization "$AUTH" >/dev/null
"${CMD[@]}" cleanup --authorization "$R/$AUTH" >/dev/null
[[ ! -e "$R/.octon/state/evidence/runs/terminal/log.txt" ]]
"${CMD[@]}" retrieve --archive-id "$AID" --output "$TMP/retrieved" >/dev/null
cmp "$TMP/retrieved/.octon/state/evidence/runs/terminal/log.txt" <(printf 'audit evidence\n')
# arbitrary destination/path escape and forged identity denied
jq '.entries[0].source_path="../escape"' "$REQ" >"$TMP/escape.json"; ! "${CMD[@]}" localize --request "$TMP/escape.json" >/dev/null 2>&1
jq '.repository_identity="sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"' "$REQ" >"$TMP/forged.json"; ! "${CMD[@]}" localize --request "$TMP/forged.json" >/dev/null 2>&1
# manual review without disposition and active runs denied
printf 'audit evidence\n' >"$R/.octon/state/evidence/runs/terminal/log.txt"
jq '.entries[0].evidence_class="manual-review" | .entries[0].manual_review_disposition=""' "$REQ" >"$TMP/manual.json"; ! "${CMD[@]}" localize --request "$TMP/manual.json" >/dev/null 2>&1
jq '.entries[0].active_state_verdict="active"' "$REQ" >"$TMP/active.json"; ! "${CMD[@]}" localize --request "$TMP/active.json" >/dev/null 2>&1
# symlink escape and unresolved lock are denied
ln -s /etc/hosts "$R/.octon/state/evidence/runs/terminal/link"; jq '.entries[0].source_path=".octon/state/evidence/runs/terminal/link"' "$REQ" >"$TMP/link.json"; ! "${CMD[@]}" localize --request "$TMP/link.json" >/dev/null 2>&1; rm "$R/.octon/state/evidence/runs/terminal/link"
mkdir -p "$R/.octon/state/control/execution/locks"; printf terminal >"$R/.octon/state/control/execution/locks/live.lock"; ! "${CMD[@]}" localize --request "$REQ" >/dev/null 2>&1; rm "$R/.octon/state/control/execution/locks/live.lock"
# incomplete and extra archive content fail verification, then recover cleanly
ADIR="$(jq -r .archive_path "$R/.octon/state/evidence/local/evidence-localization/$AID/receipt.json")"; OBJ="$(jq -r '.entries[0].destination_path' "$ADIR/manifest.json")"
cp "$ADIR/$OBJ" "$TMP/object"; rm "$ADIR/$OBJ"; ! "${CMD[@]}" verify --archive-id "$AID" >/dev/null 2>&1; cp "$TMP/object" "$ADIR/$OBJ"
printf extra >"$ADIR/extra"; ! "${CMD[@]}" verify --archive-id "$AID" >/dev/null 2>&1; rm "$ADIR/extra"; "${CMD[@]}" verify --archive-id "$AID" >/dev/null
# source drift blocks separately authorized cleanup
request "$REQ"; "${CMD[@]}" localize --request "$REQ" >/dev/null; "${CMD[@]}" authorize-cleanup --archive-id "$AID" --request "$REQ" --authorization "$AUTH" >/dev/null; printf drift >>"$R/.octon/state/evidence/runs/terminal/log.txt"; ! "${CMD[@]}" cleanup --authorization "$R/$AUTH" >/dev/null 2>&1
# expired authorization is denied
printf 'audit evidence\n' >"$R/.octon/state/evidence/runs/terminal/log.txt"; "${CMD[@]}" authorize-cleanup --archive-id "$AID" --request "$REQ" --authorization "$AUTH" >/dev/null; jq '.expires_at="2000-01-01T00:00:00Z"' "$R/$AUTH" >"$TMP/expired.json"; ! "${CMD[@]}" cleanup --authorization "$TMP/expired.json" >/dev/null 2>&1
echo '[OK] evidence localization positive and negative controls pass'
