#!/bin/sh
# Install the `ribs` CLI + its Claude skills (RIBs-KMP). Native binary, no JVM.
#
#   curl -fsSL https://raw.githubusercontent.com/The-Mobile-Engineer/RIBs-KMP/main/install.sh | sh
#
# Env overrides:
#   RIBS_INSTALL_DIR  where the `ribs` binary goes (default: ~/.local/bin)
#   RIBS_SKILLS_DIR   where the Claude skills go   (default: ~/.claude/skills)
set -eu

REPO="The-Mobile-Engineer/RIBs-KMP"
INSTALL_DIR="${RIBS_INSTALL_DIR:-$HOME/.local/bin}"
SKILLS_DIR="${RIBS_SKILLS_DIR:-$HOME/.claude/skills}"

# --- CLI binary -----------------------------------------------------------
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

mkdir -p "$INSTALL_DIR"
echo "ribs: downloading $asset …"
curl -fsSL "https://github.com/$REPO/releases/latest/download/$asset" -o "$INSTALL_DIR/ribs"
chmod +x "$INSTALL_DIR/ribs"
echo "ribs: installed CLI -> $INSTALL_DIR/ribs"

# --- Claude skills (create-rib, review-rib) -------------------------------
for skill in create-rib review-rib; do
  mkdir -p "$SKILLS_DIR/$skill"
  curl -fsSL "https://raw.githubusercontent.com/$REPO/main/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md"
done
echo "ribs: installed skills -> $SKILLS_DIR (create-rib, review-rib)"

# --- PATH hint ------------------------------------------------------------
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "ribs: add it to your PATH -> export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac
