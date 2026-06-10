# bleep-state

**State Management, Sharding & Self-Healing — BLEEP Quantum Trust Network**

`bleep-state` owns the canonical ledger state of the BLEEP blockchain: a 256-level Sparse Merkle Trie backed by RocksDB, shard lifecycle management, cross-shard two-phase commit, deterministic snapshot and rollback, and a self-healing orchestrator that transitions protocol health through Healthy → Degraded → Critical → Recovering states.

---

## License

Licensed under **Apache 2.0**.
Copyright © 2026 Muhammad Attahir.

---

## Architecture

```
bleep-state
├── state_manager              — Primary interface for all state reads and writes
├── state_merkle               — 256-level Sparse Merkle Trie (SHA3-256); fixed 8,192-byte proofs
├── state_storage              — RocksDB read/write layer (sync=true on all critical column families)
├── transaction                — State-layer transaction wrapper
│
├── Sharding (10 shards)
│   ├── shard_manager          — ShardManager: shard CRUD and routing
│   ├── shard_registry         — Global DashMap shard registry
│   ├── shard_lifecycle        — Shard create, activate, deactivate
│   ├── shard_epoch_binding    — Shard/epoch synchronisation
│   ├── shard_checkpoint       — Per-shard snapshot engine
│   ├── shard_rollback         — Shard-level rollback to checkpoint
│   ├── shard_isolation        — Fault containment boundaries
│   ├── shard_fault_detection  — AI-assisted anomaly detection per shard
│   ├── shard_healing          — Automated per-shard recovery
│   ├── shard_validator_assignment — Validator-to-shard mapping
│   └── shard_ai_extension     — AI advisory hooks for shard lifecycle decisions
│
├── Cross-Shard
│   ├── cross_shard_transaction      — CrossShardTx type
│   ├── cross_shard_2pc              — TwoPhaseCommitCoordinator
│   ├── cross_shard_locking          — Account-level distributed locks
│   ├── cross_shard_recovery         — 2PC abort and compensation
│   ├── cross_shard_safety_invariants — Cross-shard safety proofs
│   └── cross_shard_ai_hooks         — AI routing recommendations
│
└── Recovery & Healing
    ├── rollback_engine              — Full-chain rollback to epoch snapshot
    ├── snapshot_engine              — Epoch-boundary state snapshots
    ├── self_healing_orchestrator    — Fault response pipeline coordinator
    ├── advanced_fault_detector      — Multi-signal anomaly classification
    └── phase4_recovery_orchestrator — Phase 4 advanced recovery
```

---

## State Model

Each account is stored in the Sparse Merkle Trie as:

```rust
struct AccountState {
    balance:      u128,           // microBLEEP
    nonce:        u64,            // anti-replay
    code_hash:    Option<[u8; 32]>, // SHA3-256 of deployed contract code
    storage_root: [u8; 32],       // root of per-account storage trie
}
```

The global state root is SPHINCS+-signed by the block producer and verified by all validators before vote broadcast.

**Merkle proof properties:**
- Membership and non-membership proofs are both supported
- Proof size is fixed at 8,192 bytes regardless of account count
- Root appears in every block header

---

## StateManager — Primary Interface

```rust
use bleep_state::state_manager::StateManager;

let manager = StateManager::new("/var/bleep/state")?;

// Read operations
let balance = manager.balance(&address)?;
let nonce   = manager.nonce(&address)?;
let proof   = manager.merkle_proof(&address)?;   // 8,192 bytes

// Write — via StateDiff from bleep-vm (never direct writes)
manager.apply(state_diff)?;   // atomic WriteBatch, sync=true
```

---

## Cross-Shard Two-Phase Commit

Transactions touching multiple shards use `TwoPhaseCommitCoordinator`:

```
Phase 1 (Prepare):
  Coordinator sends Prepare to all affected ShardManagers
  Each shard acquires locks and returns PrepareReceipt

Phase 2 (Commit or Abort):
  If all shards returned PrepareReceipt → Commit all
  If any shard failed or timed out → Abort all; release locks
```

Coordinator assignment is derived deterministically from the transaction hash — no privileged coordinator election. Stalled coordinators are force-aborted by `cross_shard_timeout_sweep` every 60 seconds.

---

## Self-Healing Pipeline

```
AdvancedFaultDetector classifies anomaly
      ↓
SelfHealingOrchestrator activates
      ↓
  ShardFaultDetection isolates affected shard
      ↓
  RollbackEngine restores last epoch snapshot
      ↓
  ShardHealing replays validated blocks
      ↓
  Shard re-joins the active validator set
```

State transitions (Healthy → Degraded → Critical → Recovering) are deterministic. All recovery actions are logged to the tamper-evident audit log.

---

## RocksDB Column Families

Three column families have security-critical write semantics (`sync=true`, `WriteBatch`):

| Column Family | Purpose |
|---|---|
| `audit_log` | Tamper-evident Merkle-chained security event log |
| `audit_meta` | Audit log chain tip and sequence counter |
| `nullifier_store` | Double-spend prevention for ZKP cross-chain transfers |

---

## Fuzz Targets (CI-integrated)

```bash
cargo +nightly fuzz run fuzz_merkle_insert    # Sparse Merkle Trie insertion
cargo +nightly fuzz run fuzz_state_apply_tx   # State transition under malformed inputs
```

---

## Testing

```bash
cargo test -p bleep-state
```

Phase 2, Phase 4, and proptest suites: `phase2_integration_tests.rs`, `phase4_integration_tests.rs`, `proptest_sprint8.rs` (40+ property-based tests).

---

*Part of the [BLEEP Quantum Trust Network](https://github.com/BleepEcosystem/BLEEP-v1) · Protocol Version 5*
*© 2026 Muhammad Attahir — Apache 2.0 Licence*
