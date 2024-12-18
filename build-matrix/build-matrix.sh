#!/usr/bin/env bash

echo "PACKAGE_NAME: '${PACKAGE_NAME}'"
echo "PACKAGE_REPO: '${PACKAGE_REPO}'"
echo "PACKAGE_REF: '${PACKAGE_REF}'"

voulage_path="/tmp/voulage-actions-cache"

pushd "$voulage_path" >/dev/null || exit 1

cat stage/unstable/package-model.json | jq -r '.packages | .["'${PACKAGE_NAME}'"]'

echo "Supported distro/codename:"

includes=()
for dir in stage/unstable/*/*/; do
  distro=$(echo "$dir" | cut -d/ -f3)
  codename=$(echo "$dir" | cut -d/ -f4)

  cat stage/unstable/$distro/$codename/package-model.json | jq -r '.packages | .["'${PACKAGE_NAME}'"]'

  echo "  - $distro/$codename"
  include=$(
    jq \
      -n \
      -c \
      --arg distro "$distro" \
      --arg codename "$codename" \
      '$ARGS.named'
  )
  includes+=("$include")
done

popd >/dev/null || exit 1

# shellcheck disable=SC2086
jq -n "[$(printf '%s\n' "${includes[@]}" | paste -sd,)]" '$ARGS.named'
echo "includes=$(jq -n -c "[$(printf '%s\n' "${includes[@]}" | paste -sd,)]" '$ARGS.named')" >> $GITHUB_OUTPUT
