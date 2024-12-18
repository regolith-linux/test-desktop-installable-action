#!/usr/bin/env bash

set -e

echo "PACKAGE_NAME: '${PACKAGE_NAME}'"
echo "PACKAGE_REPO: '${PACKAGE_REPO}'"
echo "PACKAGE_REF: '${PACKAGE_REF}'"

voulage_path="/tmp/voulage-actions-cache"

pushd "$voulage_path" >/dev/null || exit 1

cat stage/unstable/package-model.json | jq -r '.packages | .["'${PACKAGE_NAME}'"]'

# jq -r '.packages' | jq 'has("'${NAME}'")'
# jq -r '.packages' | jq -r '.["'${NAME}'"]'

echo "Supported distro/codename:"

includes=()
for dir in stage/unstable/*/*/; do
  distro=$(echo "$dir" | cut -d/ -f3)
  codename=$(echo "$dir" | cut -d/ -f4)

  skip="false"
  ref="$PACKAGE_REF"
  model_file="stage/unstable/$distro/$codename/package-model.json"

  if [ -f $model_file ]; then
    # has_package=$(cat $model_file | jq -r '.packages | .["'${PACKAGE_NAME}'"]')
    has_package=$(cat $model_file | jq 'has("'${NAME}'")')
    echo "has_package in $distro, $codename: $has_package"

    if [ "$has_package" == "true" ]; then
      package=$(cat $model_file | jq -r '.packages' | jq -r '.["'${NAME}'"]')
      echo "the package: $package"

      if [ "$package" != "null" ]; then
        ref=$(echo $package | jq -r '.ref')
      else
        skip="true"
      fi
    fi
  fi

  if [ "$skip" == "false" ]; then
    echo "  - $distro/$codename"
    include=$(
      jq \
        -n \
        -c \
        --arg distro "$distro" \
        --arg codename "$codename" \
        --arg ref "$ref" \
        '$ARGS.named'
    )
    includes+=("$include")
  fi
done

popd >/dev/null || exit 1

# shellcheck disable=SC2086
jq -n "[$(printf '%s\n' "${includes[@]}" | paste -sd,)]" '$ARGS.named'
echo "includes=$(jq -n -c "[$(printf '%s\n' "${includes[@]}" | paste -sd,)]" '$ARGS.named')" >> $GITHUB_OUTPUT
