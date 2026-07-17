#!/bin/bash
set -euo pipefail

umask 077

if [[ $# -ne 1 ]]; then
  exit 64
fi

case "$1" in
  *Username*)
    printf '%s\n' 'x-access-token'
    ;;
  *Password*)
    fifo="${OCTON_OWNER_LANE_CREDENTIAL_FIFO:-}"
    [[ -n "$fifo" && -p "$fifo" ]] || exit 65
    mkdir -- "${fifo}.used" 2>/dev/null || exit 66
    IFS= read -r credential <"$fifo"
    [[ "$credential" == github_pat_* ]] || {
      credential=''
      exit 67
    }
    printf '%s\n' "$credential"
    credential=''
    ;;
  *)
    exit 68
    ;;
esac
