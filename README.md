# Test regolith-desktop Installable Action

Test that a package is installable on target system given public key, `apt` config, and package name.

## Usage

```yaml
name: Test if regolith-desktop is installable

on:
  workflow_dispatch:
  workflow_call:

jobs:
  ubuntu-jammy:
    runs-on: ${{ matrix.host-os }}
    strategy:
      matrix:
        stage: [unstable, testing, release-3_0, release-3_1]
        distro-codename: [ubuntu-jammy]
        arch: [amd64, arm64]
        wm: [regolith-session-flashback, regolith-session-sway]
        include:
          - arch: amd64
            host-os: [self-hosted, Linux, X64, jammy]
          - arch: arm64
            host-os: [self-hosted, Linux, ARM64, jammy]
          - distro-codename: ubuntu-jammy
            distro: ubuntu
            codename: jammy
    steps:
      - name: Test ${{ matrix.stage }} ${{ matrix.distro-codename }} ${{ matrix.arch }}
        uses: khos2ow/test-desktop-installable-action/ubuntu/jammy@main
        with:
          apt-key-url: http://regolith-desktop.org/regolith3.key
          apt-repo-line: "deb [arch=${{ matrix.arch }}] https://regolith-desktop.org/${{ matrix.stage }}-${{ matrix.distro }}-${{ matrix.codename }}-${{ matrix.arch }} ${{ matrix.codename }} main"
          target-package: "regolith-desktop ${{ matrix.wm }}"
```
