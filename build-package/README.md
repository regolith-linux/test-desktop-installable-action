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

    # suite is TODO Regolith release stage (e.g. unstable, testing, stable).
    #
    # Required.
    suite: "..."

    # component is TODO Regolith release stage (e.g. unstable, testing, stable).
    #
    # Required.
    component: "..."

    # arch is TODO Regolith release stage (e.g. unstable, testing, stable).
    #
    # Required.
    arch: "..."

    # gpg-key is the GPG private key to import.
    #
    # Required.
    gpg-key: "..."

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

      - name: Build Package
        uses: regolith-linux/actions/build-package@main
        with:
          name: "foo-package"
          distro: "ubuntu"
          codename: "noble"
          stage: "unstable"
          suite: "unstable"
          component: "main"
          arch: "amd64"
          gpg-key: "${{ secrets.GPG_PRIVATE_KEY }}"
```
