#!/bin/sh
# Install the `ribs` CLI (RIBs-KMP scaffolder). Native binary, no JVM.
#
#   curl -fsSL https://raw.githubusercontent.com/The-Mobile-Engineer/RIBs-KMP/main/install.sh | sh
#
# Override the install dir with RIBS_INSTALL_DIR (default: ~/.local/bin).
set -eu

REPO="The-Mobile-Engineer/RIBs-KMP"
INSTALL_DIR="${RIBS_INSTALL_DIR:-$HOME/.local/bin}"

os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Darwin)
    case "$arch" in
      arm64)  asset="ribs-macos-arm64" ;;
      x86_64) asset="ribs-macos-x64" ;;
      *) echo "ribs: unsupported macOS arch '$arch'"; exit 1 ;;
    esac ;;
  Linux)
    case "$arch" in
      x86_64) asset="ribs-linux-x64" ;;
      *) echo "ribs: unsupported Linux arch '$arch'"; exit 1 ;;
    esac ;;
  *) echo "ribs: unsupported OS '$os'"; exit 1 ;;
esac

url="https://github.com/$REPO/releases/latest/download/$asset"
mkdir -p "$INSTALL_DIR"
echo "ribs: downloading $asset …"
curl -fsSL "$url" -o "$INSTALL_DIR/ribs"
chmod +x "$INSTALL_DIR/ribs"
echo "ribs: installed -> $INSTALL_DIR/ribs"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "ribs: add it to your PATH -> export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
