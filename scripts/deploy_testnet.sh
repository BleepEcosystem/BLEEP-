#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
CONTRACT_DIR="$ROOT_DIR/crates/bleep-interop/contracts"

if ! command -v forge >/dev/null 2>&1; then
  echo "❌ Foundry is required to deploy the Sepolia relay contract."
  echo "   Install it with:"
  echo "     curl -L https://foundry.paradigm.xyz | bash"
  echo "     source ~/.bashrc"
  echo "     foundryup"
  exit 1
fi

if [[ -z "${SEPOLIA_RPC_URL:-}" ]]; then
  echo "❌ SEPOLIA_RPC_URL must be set to a Sepolia JSON-RPC endpoint."
  echo "   export SEPOLIA_RPC_URL=https://..."
  exit 1
fi

if [[ -z "${SEPOLIA_PRIVATE_KEY:-}" ]]; then
  echo "❌ SEPOLIA_PRIVATE_KEY must be set to the private key used for deployment."
  echo "   export SEPOLIA_PRIVATE_KEY=0x..."
  exit 1
fi

cd "$CONTRACT_DIR"

echo "🔨 Deploying BleepFulfill.sol to Sepolia via $SEPOLIA_RPC_URL"
forge script script/DeployBleepFulfill.s.sol --broadcast --rpc-url "$SEPOLIA_RPC_URL" --private-key "$SEPOLIA_PRIVATE_KEY"
