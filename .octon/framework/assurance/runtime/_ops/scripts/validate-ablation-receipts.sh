#!/usr/bin/env bash
set -euo pipefail
find .octon/state/evidence/validation/publication/build-to-delete -name '*.yml' | grep -q .

