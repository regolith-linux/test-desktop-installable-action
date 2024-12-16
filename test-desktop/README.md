# Test if `regolith-desktop` is Installable

Test that `regolith-desktop` is installable on a target system given public key,
`apt` config line, and package(s) name (e.g. `regolith-session-sway`).

## Usage

```yaml
- uses: regolith-linux/actions/test-desktop/ubuntu/noble@main
  with:
    apt-key-url: http://archive.regolith-desktop.com/regolith.key
    apt-repo-line: "deb [arch=amd64] http://archive.regolith-desktop.com/ubuntu/unstable noble main"
    target-package: "regolith-desktop regolith-session-sway"
```
