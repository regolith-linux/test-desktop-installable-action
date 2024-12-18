#!/usr/bin/env bash

set -e

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

  skip="false"
  model_file="stage/unstable/$distro/$codename/package-model.json"

  if [ -f $model_file ]; then
    packages=$(cat $model_file | jq -r '.packages')
    has_package=$(echo "$packages" | jq 'has("'${PACKAGE_NAME}'")')

    # echo "has_package in $distro, $codename: $has_package"

    if [ "$has_package" == "true" ]; then
      package=$(echo "$packages" | jq -r '.["'${PACKAGE_NAME}'"]')

      if [ "$package" != "null" ]; then
        ref=$(echo $package | jq -r '.ref')

        if [ "$ref" != "$PACKAGE_REF" ]; then
          skip="true"
          echo "  - $distro/$codename: Wrong ref ($ref)"
        fi
      else
        skip="true"
        echo "  - $distro/$codename: Skipped"
      fi
    fi
  fi

  # Skip for this distro/codename pair.
  #
  # Possible reasons:
  #  - it is explictly set to "null" in package-model
  #  - it points to some other "ref" in package model
  if [ "$skip" == "true" ]; then
    continue
  fi

  echo "  - $distro/$codename: OK"
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
