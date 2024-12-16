#!/usr/bin/env bash

voulage_path="/tmp/voulage-actions-cache"
voulage_repo="https://github.com/regolith-linux/voulage.git"
voulage_ref="main"

if [ ! -d "$voulage_path" ]; then
  git clone --quiet --no-tags --branch "$voulage_ref" "$voulage_repo" "$voulage_path"
else
  pushd "$voulage_path" >/dev/null || exit 1

  git fetch
  git checkout --quiet "$voulage_ref"
  git pull --quiet

  popd >/dev/null || exit 1
fi
