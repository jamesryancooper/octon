#!/usr/bin/env bash
# fusion.sh - Deterministic score fusion (RRF or weighted).

set -o pipefail

fuse="rrf"
top_k="20"
signals_json='{}'
weights_json='{}'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fuse)
      fuse="${2:-rrf}"
      shift 2
      ;;
    --top-k)
      top_k="${2:-20}"
      shift 2
      ;;
    --signals-json)
      signals_json="${2:-}"
      shift 2
      ;;
    --weights-json)
      weights_json="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$signals_json" ]]; then
  signals_json='{}'
fi

if [[ -z "$weights_json" ]]; then
  weights_json='{}'
fi

if ! [[ "$top_k" =~ ^[0-9]+$ ]] || (( top_k < 1 )); then
  top_k="20"
fi

if [[ "$fuse" != "rrf" && "$fuse" != "weighted" ]]; then
  echo '{"ok":false,"error":{"code":"InputValidationError","message":"fuse must be rrf or weighted."}}'
  exit 0
fi

if ! jq -e . >/dev/null 2>&1 <<<"$signals_json"; then
  echo '{"ok":false,"error":{"code":"InputValidationError","message":"--signals-json must be valid JSON."}}'
  exit 0
fi

if ! jq -e . >/dev/null 2>&1 <<<"$weights_json"; then
  echo '{"ok":false,"error":{"code":"InputValidationError","message":"--weights-json must be valid JSON."}}'
  exit 0
fi

candidates_json="$(jq -n \
  --arg fuse "$fuse" \
  --argjson topk "$top_k" \
  --argjson signals "$signals_json" \
  --argjson weights "$weights_json" '
  def signal_names: ["keyword", "semantic", "graph"];
  def sorted($arr): (($arr // []) | sort_by(-(.score // 0), .chunk_id));

  (signal_names | map(select(($signals[.] // []) | length > 0))) as $enabled
  | ($enabled | length) as $enabled_count
  | (if $enabled_count > 0 then (1 / $enabled_count) else 0 end) as $default_weight
  | (reduce $enabled[] as $s ({}; .[$s] = sorted($signals[$s]))) as $sorted
  | (reduce $enabled[] as $s ({};
      . + (
        reduce range(0; ($sorted[$s] | length)) as $i ({};
          ($sorted[$s][$i]) as $c
          | ($c.chunk_id // "") as $cid
          | if ($cid | length) == 0 then . else
              .[$cid] = ((.[$cid] // []) + [{
                signal: $s,
                rank: ($i + 1),
                raw_score: ($c.score // 0),
                doc_id: ($c.doc_id // ""),
                locator: ($c.locator // "")
              }])
            end
        )
      )
    )) as $grouped
  | (reduce ($grouped | keys[]) as $cid ([];
      . + [
        ($grouped[$cid]) as $entries
        | ($entries[0]) as $first
        | {
            chunk_id: $cid,
            doc_id: ($first.doc_id // (if ($cid | contains("#")) then ($cid | split("#")[0]) else "_unknown" end)),
            locator: ($first.locator // (($first.doc_id // "_unknown") + "#" + $cid)),
            signals: (
              reduce $entries[] as $e ({};
                .[$e.signal] = (
                  if $fuse == "rrf" then
                    (1 / (60 + $e.rank))
                  else
                    (($weights[$e.signal] // $default_weight) * ($e.raw_score | tonumber))
                  end
                )
              )
            ),
            score: (
              reduce $entries[] as $e (0;
                . + (
                  if $fuse == "rrf" then
                    (1 / (60 + $e.rank))
                  else
                    (($weights[$e.signal] // $default_weight) * ($e.raw_score | tonumber))
                  end
                )
              )
            )
          }
      ]
    ))
  | sort_by(-.score, .chunk_id)
  | .[:$topk]
  | to_entries
  | map(.value + {rank: (.key + 1)})
')"

jq -n --argjson candidates "$candidates_json" '{ok:true,candidates:$candidates}'
