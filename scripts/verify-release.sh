#!/usr/bin/env bash
set -euo pipefail

tag_version="${1:-}"
if [[ -n "$tag_version" ]]; then
  tag_version="${tag_version#V}"
fi

package_version="$(sed -nE 's/^let lexlightVersion = "([^"]+)"$/\1/p' Package.swift)"
swift_version="$(
  sed -nE 's/^[[:space:]]*public static let current = "([^"]+)"$/\1/p' \
    Sources/Lexlight/LexlightVersion.swift
)"
manifest_version="$(node -p "require('./Sources/Lexlight/Resources/resource-manifest.json').lexlightVersion")"
npm_version="$(node -p "require('./package.json').version")"

for value in "$package_version" "$swift_version" "$manifest_version" "$npm_version"; do
  if [[ -z "$value" ]]; then
    echo "verify-release: could not read every version field" >&2
    exit 1
  fi
done

if [[ "$package_version" != "$swift_version" ]] ||
  [[ "$package_version" != "$manifest_version" ]] ||
  [[ "$package_version" != "$npm_version" ]]; then
  echo "verify-release: package=$package_version swift=$swift_version manifest=$manifest_version npm=$npm_version" >&2
  exit 1
fi

if [[ -n "$tag_version" && "$tag_version" != "$package_version" ]]; then
  echo "verify-release: tag=$tag_version package=$package_version" >&2
  exit 1
fi

echo "verify-release: Lexlight $package_version"
