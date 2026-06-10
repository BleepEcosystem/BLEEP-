# bleep-consensus

**Post-Quantum BFT Consensus Engine — BLEEP Quantum Trust Network**

`bleep-consensus` implements BLEEP's multi-mode proof-of-stake Byzantine fault-tolerant consensus. It produces SPHINCS+-signed blocks with embedded Winterfell STARK validity proofs, manages epoch transitions, enforces deterministic slashing, and coordinates across 10 shards — all under a strict safety-over-liveliness design principle.

---

## License

Licensed under **Apache 2.0**.
Copyright © 2026 Muhammad Attahir.

---

## Architecture

```
bleep-consensus
├── consensus              — BLEEPAdaptiveConsensus, ConsensusMode, Validator
├── engine                 — ConsensusEngine trait, ConsensusError, ConsensusMetrics
├── pos_engine             — PoS-Normal: primary mode, stake-proportional proposer selection
├── pbft_engine            — PBFT: emergency mode, reduced validator set
├── pow_engine             — PoW: fallback mode, censorship-resistant
├── orchestrator           — ConsensusOrchestrator: mode selection and delegation
├── block_producer         — Block assembly, STARK proof generation, SPHINCS+ signing, broadcast
├── epoch                  — EpochConfig, EpochState, epoch transition logic
├── finality               — FinalityManager: irreversible finalisation at >6,667 bps stake
├── slashing_engine        — SlashingEngine: double-sign, equivocation, downtime penalties
├── ai_adaptive_logic      — linfa k-NN consensus mode predictor
├── ai_advisory            — AI advisory hooks (non-blocking, advisory only)
├── gossip_bridge          — Async bridge from consensus to bleep-p2p
├── shard_coordinator      — Cross-shard transaction routing during consensus
├── recovery_controller    — Recovery mode re-anchor after partition
├── safety_invariants      — Protocol safety invariant assertions
├── incident_detector      — Anomaly and incident classification
├── self_healing_orchestrator — Consensus-layer fault recovery
├── chaos_engine           — ChaosEngine: fault injection for adversarial testing
├── performance_bench      — TPS benchmarking (TARGET_TPS, BENCHMARK_DURATION_SECS)
└── security_audit         — On-demand AuditReport generation
```

---

## Consensus Modes

Three deterministic modes selected by `ConsensusOrchestrator` based on validator liveness metrics. Mode selection is deterministic — identical liveness inputs produce identical mode on all honest nodes.

| Mode | Trigger Condition | Block Interval | Primary Characteristic |
|---|---|---|---|
| **PoS-Normal** | Primary — healthy validator set | 3,000 ms | Stake-proportional proposer selection |
| **Emergency (PBFT)** | <67% validators responsive | 3,000 ms | Reduced validator set, safety-first |
| **Recovery (PoW)** | Post-partition re-anchor | Variable | Censorship-resistant, deterministic re-sync |

Mode switches are logged, signed, and traceable in the tamper-evident audit log.

### AI-Adaptive Mode Selection

`ai_adaptive_logic.rs` uses a linfa k-nearest-neighbour model trained on network telemetry to predict optimal mode. It is advisory — the final selection is deterministic from validator liveness data, not from model output alone. The model has no authority to override the BFT safety invariant.

---

## Block Production Pipeline

Every block produced by `BlockProducer` follows this sequence:

```
1. Select up to MAX_TXS_PER_BLOCK (4,096) transactions by fee — descending order
2. Compute Sparse Merkle Trie root over resulting state
3. Generate Winterfell STARK BlockValidityProof via BlockValidityProver
   — 48-column execution trace, f128 field, FRI backend
   — avg ~850ms on reference hardware (8-core, 32 GB RAM)
   — no trusted setup required
4. Sign completed block with SPHINCS+-SHAKE-256f-simple (FIPS 205, SL5)
5. Broadcast via bleep-p2p gossip
```

Both the STARK proof and the SPHINCS+ signature are required for a block to be accepted. A block with a valid signature but invalid STARK proof is rejected.

---

## Epoch Lifecycle

Each epoch (1,000 blocks on mainnet / 100 blocks on testnet):

1. `EpochConfig` determines validator set membership and shard assignments
2. `ConsensusOrchestrator::select_mode()` evaluates `ConsensusMetrics`
3. Selected engine produces and validates blocks for the epoch duration
4. `SlashingEngine` sweeps for and processes all pending evidence
5. `FinalityManager` emits `FinalityCertificate` for the epoch's terminal block
6. Validator rewards distributed by `bleep-economics` epoch hooks

---

## Finality

`FinalityManager` finalises blocks when precommits representing **>6,667 bps (66.67%) of total staked supply** are received. Finalisation is irreversible. Long-range reorgs are rejected regardless of claimed proof-of-work — verified in the adversarial test suite at depths of 10 and 50 blocks.

---

## Slashing

| Violation | Penalty | Source Constant |
|---|---|---|
| Double-sign | **33% of stake burned**; validator tombstoned | `double_signing_penalty: 0.33` |
| Equivocation | **25% of stake burned** | `equivocation_penalty: 0.25` |
| Downtime | **0.1% per consecutive missed block** | `downtime_penalty_per_block` |

Evidence is submitted via `POST /rpc/validator/evidence` and processed by `SlashingEngine`. All slashing actions are written to the tamper-evident audit log with the evidence hash.

---

## Adversarial Test Coverage

The following scenarios are covered in the 72-hour adversarial test suite:

| Scenario | Expected Result |
|---|---|
| `ValidatorCrash(1)` | Consensus resumed — f=1 < n/3 |
| `ValidatorCrash(2)` | Consensus resumed — f=2 < n/3 |
| `NetworkPartition(4/3)` | Majority partition continued; healed cleanly |
| `LongRangeReorg(10)` | Rejected at `FinalityManager` |
| `LongRangeReorg(50)` | Rejected at `FinalityManager` |
| `DoubleSign(validator-0)` | 33% slashed; evidence committed; tombstoned |
| `STARKProofTamper` | Tampered proof rejected at `BlockValidityVerifier` |
| `LoadStress(10,000 TPS, 60s)` | Max throughput; STARK proofs generated within slot budget |

---

## Protocol Constants

| Constant | Value | Description |
|---|---|---|
| `BLOCK_INTERVAL_MS` | 3,000 | Target block time in milliseconds |
| `MAX_TXS_PER_BLOCK` | 4,096 | Maximum transactions per block |
| `BLOCKS_PER_EPOCH` | 1,000 (mainnet) / 100 (testnet) | Epoch length |
| `FINALITY_THRESHOLD_BPS` | 6,667 | Minimum stake basis points for finalisation |
| `NUM_SHARDS` | 10 | Active shard count |

---

## Quick Start

```rust
use bleep_consensus::run_consensus_engine;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    run_consensus_engine().await
}
```

---

## Testing

```bash
# Full test suite
cargo test -p bleep-consensus

# Chaos and adversarial scenarios
cargo test -p bleep-consensus chaos

# Performance benchmark
cargo test -p bleep-consensus bench
```

---

*Part of the [BLEEP Quantum Trust Network](https://github.com/BleepEcosystem/BLEEP-v1) · Protocol Version 5*
*© 2026 Muhammad Attahir — Apache 2.0 Licence*
