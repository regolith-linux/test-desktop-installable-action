#!/usr/bin/env bash

set -e

voulage_path="/tmp/voulage-actions-cache"

pushd "$voulage_path" >/dev/null || exit 1

echo "Building ${PACKAGE_NAME} @ ${PACKAGE_REF} for ${DISTRO}/${CODENAME} (${STAGE})..."

export DEBEMAIL="${GPG_EMAIL}"
export DEBFULLNAME="${GPG_NAME}"

.github/scripts/local-build.sh \
  --extension .github/scripts/ext-debian.sh \
  --git-repo-path "/tmp/voulage-actions-cache" \
  --package-name "${PACKAGE_NAME}" \
  --package-url "${PACKAGE_URL}" \
  --package-ref "${PACKAGE_REF}" \
  --distro "${DISTRO}" \
  --codename "${CODENAME}" \
  --stage "${STAGE}"

popd >/dev/null || exit 1
