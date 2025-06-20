#!/bin/sh

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
WRAPPER="$INSTALL_DIR/iko"

mkdir -p "$INSTALL_DIR"

cat > "$WRAPPER" <<'EOF'
#!/bin/sh
set -euo pipefail

[ -f .env ] && source .env

ENV_ARG=""
[ -f .env ] && ENV_ARG="--env-file .env"

IKORC_ARG=""
IKORC_PATH="${IKORC_PATH:-$HOME/.config/ikorc}"
[ -f "$IKORC_PATH" ] && IKORC_ARG="-v $IKORC_PATH:/home/.ikorc:ro"

docker run --rm -it \
  $ENV_ARG \
  $IKORC_ARG \
  --network "${DOCKER_NETWORK:-bridge}" \
  -v "${PWD}/migrations:/repo:rw" \
  -v "${PWD}/scripts:/scripts:ro" \
  ghcr.io/explodinglabs/iko:0.1.0 "$@"
EOF

chmod +x "$WRAPPER"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "✅ Installed iko to $WRAPPER"
  echo "⚠️  Warning: $INSTALL_DIR is not in your PATH. Add this to your shell profile:"
  echo 'export PATH="$HOME/.local/bin:$PATH"'
else
  echo "✅ Installed iko. You can now run: iko"
fi
