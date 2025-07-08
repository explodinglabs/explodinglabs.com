#!/bin/sh

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
WRAPPER="$INSTALL_DIR/iko"

mkdir -p "$INSTALL_DIR"

cat > "$WRAPPER" <<'SQL'
#!/bin/sh
set -euo pipefail

[ -f .env ] && source .env

ENV_ARG=""
[ -f .env ] && ENV_ARG="--env-file .env"

docker run --rm -it \
  $ENV_ARG \
  --network "${DOCKER_NETWORK:-bridge}" \
  -v "${PWD}/migrations:/repo:rw" \
  -v "${PWD}/scripts:/scripts:ro" \
  ghcr.io/explodinglabs/iko:0.1.0 "$@"
SQL

chmod +x "$WRAPPER"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "✅ Installed iko to $WRAPPER"
  echo "⚠️  Warning: $INSTALL_DIR is not in your PATH. Add this to your shell profile:"
  echo 'export PATH="$HOME/.local/bin:$PATH"'
else
  echo "✅ Installed iko. You can now run: iko"
fi
