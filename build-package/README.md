# Build Package

Build a package for speficied distro/codename/stage triplet. It uses package
name, package repo, and package ref to checkout the code.

## Usage

```yaml
- uses: regolith-linux/actions/build-package@main
  with:
    # name of the package to build.
    #
    # Required.
    name: "..."

    # repo is the package git repository URL (it can be both ssh and https).
    #
    # Required.
    repo: "..."

    # ref is a valid git repository ref to checkout the code from (e.g. branch, tag, or hash).
    #
    # Required.
    ref: "..."

    # distro is the target distro to build the package for (debian, ubuntu).
    #
    # Required.
    distro: "..."

    # codename is the target codename to build the package for (e.g. focal, bullseye).
    #
    # Required.
    codename: "..."

    # stage is Regolith release stage (e.g. unstable, testing, stable).
    #
    # Required.
    stage: "..."

    # gpg-email is the email ID associated with the GPG Key.
    #
    # Required.
    gpg-email: "regolith.linux@gmail.com"

    # gpg-name is the full name associated with the GPG Key.
    #
    # Required.
    gpg-name: "Regolith Linux"
```

## Scenarios

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    container: "ubuntu:noble"
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Import GPG Key
        uses: regolith-linux/actions/import-gpg@main
        with:
          gpg-key: "${{ secrets.GPG_PRIVATE_KEY }}"

      - name: Build Package
        uses: regolith-linux/actions/build-package@main
        with:
          name: "foo-package"
          repo: "https://github.com/${{ github.repository }}"
          ref: "${{ github.ref }}"
          distro: "ubuntu"
          codename: "noble"
```
