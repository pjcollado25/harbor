#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter run -d "iPhone 17" \
  --dart-define=HARBOR_SEED_DEMO=true \
  "$@"
