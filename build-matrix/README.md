# Build Matrix of Supported OS

Build a matrix of currently supported distros and codenames in encoded JSON list
format. The list is being built out of `stage/unstable` folder of [voulage].

## Usage

```yaml
- uses: regolith-linux/actions/build-matrix@main
```

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| `includes` | Encoded JSON list of matrix `include` items | <pre>[{<br>&emsp;&emsp;"distro": "ubuntu",<br>&emsp;&emsp;"codename": "noble"<br>}, {<br>&emsp;&emsp;"distro": "ubuntu",<br>&emsp;&emsp;"codename": "oracular"<br>}]</pre> |

## Scenarios

```yaml
jobs:
  matrix-builder:
    runs-on: ubuntu-24.04
    outputs:
      includes: ${{ steps.builder.outputs.includes }}
    steps:
      - name: Build Matrix
        id: builder
        uses: regolith-linux/actions/build-matrix@main

  build:
    runs-on: ubuntu-24.04
    container: "${{ matrix.distro }}:${{ matrix.codename }}"
    needs: matrix-builder
    strategy:
      fail-fast: false
      matrix:
        include: ${{ fromJSON(needs.matrix-builder.outputs.includes) }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build Package
        uses: regolith-linux/actions/build-package@main
        with:
          name: "foo-package"
          repo: "https://github.com/${{ github.repository }}"
          ref: "${{ github.ref }}"
          distro: "${{ matrix.distro }}"
          codename: "${{ matrix.codename }}"
```

[voulage]: https://github.com/regolith-linux/voulage/
