#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

bash "$PROJECT_DIR/scripts/build.sh"

echo "==> Launching..."
open "$PROJECT_DIR/build/PhotoSlideshow.app"
