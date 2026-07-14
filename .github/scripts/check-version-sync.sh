#!/usr/bin/env bash
set -euo pipefail

TAG_NAME="${1:-${GITHUB_REF_NAME:-}}"
if [[ -z "${TAG_NAME}" ]]; then
  echo "Error: no tag provided. Pass a tag argument or set GITHUB_REF_NAME." >&2
  exit 1
fi

if [[ ! "${TAG_NAME}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: tag '${TAG_NAME}' must match vMAJOR.MINOR.PATCH (example: v1.0.0)." >&2
  exit 1
fi

TAG_VERSION="${TAG_NAME#v}"

PROJECT_PATH="StepCollector/StepCollector.xcodeproj"
SCHEME="StepCollector"

if [[ ! -d "${PROJECT_PATH}" ]]; then
  echo "Error: could not find Xcode project at ${PROJECT_PATH}." >&2
  exit 1
fi

RAW_MARKETING_VERSION="$(
  xcodebuild -project "${PROJECT_PATH}" -scheme "${SCHEME}" -configuration Release -showBuildSettings 2>/dev/null \
    | awk -F'= ' '/MARKETING_VERSION/ {print $2; exit}'
)"

if [[ -z "${RAW_MARKETING_VERSION}" ]]; then
  echo "Error: failed to read MARKETING_VERSION from Xcode build settings." >&2
  exit 1
fi

normalize_version() {
  local v="$1"
  while [[ "$v" == *".0" ]]; do
    v="${v%.0}"
  done
  echo "$v"
}

NORMALIZED_TAG="$(normalize_version "${TAG_VERSION}")"
NORMALIZED_MARKETING="$(normalize_version "${RAW_MARKETING_VERSION}")"

echo "Tag version: ${TAG_VERSION}"
echo "Xcode MARKETING_VERSION: ${RAW_MARKETING_VERSION}"

if [[ "${NORMALIZED_TAG}" != "${NORMALIZED_MARKETING}" ]]; then
  echo "Error: version mismatch. Tag '${TAG_NAME}' does not match MARKETING_VERSION '${RAW_MARKETING_VERSION}'." >&2
  exit 1
fi

echo "Version check passed."
