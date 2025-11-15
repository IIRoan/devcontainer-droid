# Droid CLI Dev Container Feature

This repository packages the Factory **Droid CLI** as a reusable [Dev Container Feature](https://containers.dev/guide/author-a-feature). The feature defers to the official upstream installer script so you always get the latest published release with minimal maintenance.

## Feature Contents

- Fetches and executes the `https://app.factory.ai/cli` installation script as the dev container user.
- Leaves all version discovery and checksum validation to the upstream script (latest release by default).
- Symlinks the resulting `droid` and bundled `ripgrep` binaries into `/usr/local/bin` so they're immediately available on the PATH.

## Usage

Add the feature in your `devcontainer.json`.

```jsonc
{
  "features": {
    "ghcr.io/iiroan/devcontainer-droid/droid-cli:1": {}
  },
}
```
