#!/usr/bin/env bash
# build-filesystem-interfaces-benchmark-fixture.sh - generate deterministic benchmark tree.

set -o pipefail

OCTON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../" && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/../.." && pwd)"
PROFILE_FILE="$OCTON_DIR/capabilities/runtime/services/interfaces/filesystem-snapshot/fixtures/benchmark-profile.tsv"

profile="ci"
fixture_root=""

usage() {
  cat <<USAGE
Usage: $0 [--profile ci|standard] [--fixture-root <repo-relative-path>]

Rebuilds fixture_root from scratch (existing contents are removed).

Outputs key=value lines:
  fixture_root
  fixture_path
  profile
  top_dirs
  files_per_dir
  lines_per_file
  files_created
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --fixture-root)
      fixture_root="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$profile" ]]; then
  echo "ERROR: --profile must be non-empty" >&2
  exit 1
fi

if [[ ! -f "$PROFILE_FILE" ]]; then
  echo "ERROR: benchmark profile not found: $PROFILE_FILE" >&2
  exit 1
fi

top_dirs=""
files_per_dir=""
lines_per_file=""
while IFS=$'\t' read -r p td fpd lpf; do
  [[ -z "$p" ]] && continue
  [[ "$p" =~ ^# ]] && continue
  if [[ "$p" == "$profile" ]]; then
    top_dirs="$td"
    files_per_dir="$fpd"
    lines_per_file="$lpf"
    break
  fi
done < "$PROFILE_FILE"

if [[ -z "$top_dirs" || -z "$files_per_dir" || -z "$lines_per_file" ]]; then
  echo "ERROR: profile '$profile' not found in $PROFILE_FILE" >&2
  exit 1
fi

if [[ -z "$fixture_root" ]]; then
  run_id="$(date +%s)-$$"
  fixture_root=".octon/generated/.tmp/filesystem-interfaces-bench/${profile}-${run_id}"
fi

if [[ "$fixture_root" = /* || "$fixture_root" == *".."* ]]; then
  echo "ERROR: fixture root must be a safe repo-relative path: $fixture_root" >&2
  exit 1
fi

if [[ "$fixture_root" == "." || "$fixture_root" == "./" ]]; then
  echo "ERROR: fixture root cannot be the repository root" >&2
  exit 1
fi

fixture_path="$REPO_ROOT/$fixture_root"
if [[ "$fixture_path" == "$REPO_ROOT" || "$fixture_path" == "/" ]]; then
  echo "ERROR: refusing to reset unsafe fixture path: $fixture_path" >&2
  exit 1
fi

rm -rf "$fixture_path"
mkdir -p "$fixture_path"

topics=(auth billing graph runtime snapshot policy discovery interop ownership provenance)
files_created=0

for d in $(seq 0 $((top_dirs - 1))); do
  module="module-$(printf '%02d' "$d")"
  for section in docs src notes; do
    mkdir -p "$fixture_path/$module/$section"
  done

  for f in $(seq 0 $((files_per_dir - 1))); do
    section_index=$((f % 3))
    case "$section_index" in
      0)
        section="docs"
        ext="md"
        ;;
      1)
        section="src"
        ext="txt"
        ;;
      *)
        section="notes"
        ext="txt"
        ;;
    esac

    topic="${topics[$(((d + f) % ${#topics[@]}))]}"
    file_path="$fixture_path/$module/$section/doc-$(printf '%03d' "$f").$ext"

    {
      printf "benchmark-profile=%s\n" "$profile"
      printf "module=%s section=%s file=%03d topic=%s bench-keyword\n" "$module" "$section" "$f" "$topic"
      for line in $(seq 1 "$lines_per_file"); do
        printf "line=%02d module=%s topic=%s signal=bench-keyword index=%04d\n" "$line" "$module" "$topic" $((d * files_per_dir + f))
      done
    } > "$file_path"

    files_created=$((files_created + 1))
  done
done

echo "fixture_root=$fixture_root"
echo "fixture_path=$fixture_path"
echo "profile=$profile"
echo "top_dirs=$top_dirs"
echo "files_per_dir=$files_per_dir"
echo "lines_per_file=$lines_per_file"
echo "files_created=$files_created"
